from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.models import User, Profile, LifestylePreference
from app.schemas.schemas import UserSignup, UserLogin, Token, UserResponse, RefreshTokenRequest
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_token
from app.api.deps import get_current_user
import uuid

router = APIRouter()

@router.post("/signup", response_model=UserResponse)
def signup(data: UserSignup, db: Session = Depends(get_db)):
    # Check if user already exists
    existing = db.query(User).filter(User.email == data.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email is already registered."
        )
    
    # Create new User
    user = User(
        email=data.email,
        hashed_password=get_password_hash(data.password),
        phone=data.phone,
        role=data.role if data.role else "user",
        is_verified=False
    )
    db.add(user)
    db.flush() # populate user ID

    # Create associated empty Profile & Lifestyle preference structure
    profile = Profile(
        user_id=user.id,
        full_name=data.email.split("@")[0].capitalize(),
        budget_max=10000.00, # default placeholder budget max
        verification_status="pending"
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
    # Simulated Google authentication logic. Creates user if they don't exist.
    email = google_token.get("email")
    if not email:
        raise HTTPException(status_code=400, detail="Google authentication failed - email not found")
        
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
            full_name=google_token.get("name", email.split("@")[0].capitalize()),
            budget_max=10000.00,
            avatar_url=google_token.get("picture"),
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

@router.post("/forgot-password")
def forgot_password(email_dict: dict):
    # Simulated email recovery link triggers
    return {"status": "ok", "message": "Password recovery instructions sent if email exists."}

@router.post("/verify-email")
def verify_email(verification_dict: dict, db: Session = Depends(get_db)):
    email = verification_dict.get("email")
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_verified = True
    db.commit()
    return {"status": "ok", "message": "Email verified successfully."}

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user
