from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.models import User, Profile, LifestylePreference
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_token
from app.api.deps import get_current_user
from app.services.email_service import EmailService
from app.schemas.schemas import UserSignup, UserLogin, Token, UserResponse, RefreshTokenRequest, OTPRequest, OTPVerify, IdentityVerifyRequest
import random
import uuid
import os
from datetime import datetime, timedelta
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

router = APIRouter()

# In-memory OTP storage cache with expiration & rate limiting
# Schema: { email: {"code": "123456", "expires_at": datetime, "attempts": 0, "last_sent": datetime} }
OTP_STORE = {}

def _generate_and_send_otp(email: str, user_name: str = "User") -> str:
    now = datetime.utcnow()
    
    # Rate limiting: max 1 OTP request per 30 seconds
    if email in OTP_STORE:
        last_sent = OTP_STORE[email].get("last_sent")
        if last_sent and (now - last_sent).total_seconds() < 30:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Please wait 30 seconds before requesting another verification code."
            )

    code = f"{random.randint(100000, 999999)}"
    OTP_STORE[email] = {
        "code": code,
        "expires_at": now + timedelta(minutes=10),
        "attempts": 0,
        "last_sent": now
    }
    
    EmailService.send_verification_otp(to_email=email, otp_code=code, user_name=user_name)
    return code

@router.post("/signup", response_model=UserResponse)
def signup(data: UserSignup, db: Session = Depends(get_db)):
    # Check if user already exists
    existing = db.query(User).filter(User.email == data.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email is already registered."
        )
    
    # Check if email belongs to designated system admin accounts
    ADMIN_EMAILS = {"mail.cohabio@gmail.com", "founder.cohabio@gmail.com", "admin@cohabio.com", "ceo@cohabio.com"}
    assigned_role = "admin" if data.email.lower() in ADMIN_EMAILS else (data.role if data.role else "user")

    # Create new User
    user = User(
        email=data.email,
        hashed_password=get_password_hash(data.password),
        phone=data.phone,
        role=assigned_role,
        is_verified=False
    )
    db.add(user)
    db.flush() # populate user ID


    # Create associated empty Profile & Lifestyle preference structure
    profile = Profile(
        user_id=user.id,
        full_name=data.email.split("@")[0].capitalize(),
        budget_max=10000.00,
        verification_status="UNVERIFIED"
    )
    db.add(profile)
    db.flush()

    lifestyle = LifestylePreference(
        profile_id=profile.id,
        food_pref="any",
        smoking=False,
        drinking="socially",
        pets="no",
        sleep_schedule="flexible",
        work_schedule="flexible",
        cleanliness_rating=3,
        interests=[]
    )
    db.add(lifestyle)
    db.commit()
    db.refresh(user)

    # Auto-dispatch email verification OTP
    try:
        _generate_and_send_otp(user.email, profile.full_name)
    except Exception as e:
        print(f"Failed to auto-send signup OTP: {e}")

    return user

@router.post("/login", response_model=Token)
def login(data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or not user.hashed_password or not verify_password(data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    
    access_token = create_access_token(subject=user.id, role=user.role)
    refresh_token = create_refresh_token(subject=user.id, role=user.role)
    return Token(
        access_token=access_token,
        token_type="bearer",
        refresh_token=refresh_token,
        user_id=user.id,
        role=user.role
    )

@router.post("/refresh", response_model=Token)
def refresh_token(data: RefreshTokenRequest, db: Session = Depends(get_db)):
    payload = decode_token(data.refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    access_token = create_access_token(subject=user.id, role=user.role)
    new_refresh = create_refresh_token(subject=user.id, role=user.role)
    return Token(
        access_token=access_token,
        token_type="bearer",
        refresh_token=new_refresh,
        user_id=user.id,
        role=user.role
    )

@router.post("/google", response_model=Token)
def login_google(google_token: dict, db: Session = Depends(get_db)):
    # Validate the Google ID Token
    token = google_token.get("token")
    if not token:
        raise HTTPException(status_code=400, detail="Google authentication failed - no token provided")
    
    # Using environment variable for Client ID, falling back to a dummy for development if missing
    GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "YOUR_GOOGLE_WEB_CLIENT_ID")
    
    try:
        idinfo = id_token.verify_oauth2_token(
            token, google_requests.Request(), GOOGLE_CLIENT_ID
        )
        
        # ID token is valid. Extract user info.
        email = idinfo.get("email")
        name = idinfo.get("name", email.split("@")[0].capitalize())
        picture = idinfo.get("picture")
        
        if not email:
            raise ValueError("Token didn't contain an email.")
            
    except ValueError as e:
        # Invalid token
        raise HTTPException(status_code=401, detail=f"Invalid Google token: {str(e)}")

    user = db.query(User).filter(User.email == email).first()
    if not user:
        user = User(
            email=email,
            hashed_password=None,
            phone=None,
            role="user",
            is_verified=True
        )
        db.add(user)
        db.flush()
        profile = Profile(
            user_id=user.id,
            full_name=name,
            budget_max=10000.00,
            avatar_url=picture,
            verification_status="verified"
        )
        db.add(profile)
        db.flush()
        lifestyle = LifestylePreference(
            profile_id=profile.id
        )
        db.add(lifestyle)
        db.commit()
        db.refresh(user)

    access_token = create_access_token(subject=user.id, role=user.role)
    refresh_token = create_refresh_token(subject=user.id, role=user.role)
    return Token(
        access_token=access_token,
        token_type="bearer",
        refresh_token=refresh_token,
        user_id=user.id,
        role=user.role
    )

@router.post("/apple", response_model=Token)
def login_apple(apple_token: dict, db: Session = Depends(get_db)):
    # Simulated Apple authentication logic.
    email = apple_token.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Apple authentication failed - email not found")
        
    user = db.query(User).filter(User.email == email).first()
    if not user:
        user = User(
            email=email,
            hashed_password=None,
            phone=None,
            role="user",
            is_verified=True
        )
        db.add(user)
        db.flush()
        profile = Profile(
            user_id=user.id,
            full_name=apple_token.get("name", email.split("@")[0].capitalize()),
            budget_max=10000.00,
            verification_status="verified"
        )
        db.add(profile)
        db.flush()
        lifestyle = LifestylePreference(
            profile_id=profile.id
        )
        db.add(lifestyle)
        db.commit()
        db.refresh(user)

    access_token = create_access_token(subject=user.id, role=user.role)
    refresh_token = create_refresh_token(subject=user.id, role=user.role)
    return Token(
        access_token=access_token,
        token_type="bearer",
        refresh_token=refresh_token,
        user_id=user.id,
        role=user.role
    )

@router.post("/send-otp")
def send_otp(req: OTPRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="No registered account found with this email.")
    
    user_name = user.profile.full_name if user.profile else "CoHabio User"
    code = _generate_and_send_otp(req.email, user_name)
    return {"status": "ok", "message": f"Verification OTP code sent to {req.email}"}

@router.post("/verify-otp")
def verify_otp(req: OTPVerify, db: Session = Depends(get_db)):
    email = req.email.strip()
    code = req.code.strip()
    
    if email not in OTP_STORE:
        raise HTTPException(status_code=400, detail="No verification code requested for this email or token expired.")
    
    record = OTP_STORE[email]
    
    # Check expiration (10 minutes)
    if datetime.utcnow() > record["expires_at"]:
        del OTP_STORE[email]
        raise HTTPException(status_code=400, detail="Verification OTP code has expired. Please request a new code.")
    
    # Check attempt threshold (max 5 failed attempts)
    if record["attempts"] >= 5:
        del OTP_STORE[email]
        raise HTTPException(status_code=429, detail="Too many invalid attempts. Please request a new verification code.")
    
    if record["code"] != code:
        record["attempts"] += 1
        raise HTTPException(status_code=400, detail=f"Invalid verification code. {5 - record['attempts']} attempts remaining.")
    
    # Successful verification! Consume token so it cannot be reused.
    del OTP_STORE[email]
    
    user = db.query(User).filter(User.email == email).first()
    if user:
        user.is_verified = True
        if user.profile:
            user.profile.verification_status = "EMAIL_VERIFIED"
        db.commit()
    
    return {
        "status": "ok",
        "message": "Level 1: Email verification completed successfully!",
        "verification_level": "EMAIL_VERIFIED"
    }

@router.post("/verify-identity")
def verify_identity(req: IdentityVerifyRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """
    Level 2: Identity & Document Verification.
    Updates verification_status to IDENTITY_VERIFIED and notifies the user.
    """
    if not current_user.is_verified:
        raise HTTPException(
            status_code=400,
            detail="Please verify your email address (Level 1) before submitting identity verification."
        )
    
    if not req.id_number or len(req.id_number.strip()) < 4:
        raise HTTPException(status_code=400, detail="Please provide a valid document identification number.")
    
    profile = current_user.profile
    if profile:
        profile.verification_status = "IDENTITY_VERIFIED"
        if req.college_or_company:
            profile.college = req.college_or_company
        db.commit()
    
    EmailService.send_verification_status_update(
        to_email=current_user.email,
        user_name=profile.full_name if profile else "User",
        status_text="IDENTITY_VERIFIED"
    )
    
    return {
        "status": "ok",
        "message": "Level 2 Identity Verification successful! Your roomie verification badge is now active.",
        "verification_status": "IDENTITY_VERIFIED"
    }

@router.post("/forgot-password")
def forgot_password(email_dict: dict, db: Session = Depends(get_db)):
    email = email_dict.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Email is required.")
    user = db.query(User).filter(User.email == email).first()
    if user:
        _generate_and_send_otp(email, user.profile.full_name if user.profile else "User")
    return {"status": "ok", "message": "Password recovery instructions sent if email exists."}

@router.post("/verify-email")
def verify_email(verification_dict: dict, db: Session = Depends(get_db)):
    email = verification_dict.get("email")
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_verified = True
    if user.profile:
        user.profile.verification_status = "EMAIL_VERIFIED"
    db.commit()
    return {"status": "ok", "message": "Email verified successfully."}

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user
