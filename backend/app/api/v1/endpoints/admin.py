from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.models import User, Profile, Report, Waitlist
from app.schemas.schemas import ReportResponse, ProfileResponse, WaitlistResponse
from app.api.deps import get_admin_user, get_moderator_user
from typing import List
import uuid

router = APIRouter()

@router.get("/reports", response_model=List[ReportResponse])
def list_reports(db: Session = Depends(get_db), current_admin = get_moderator_user):
    reports = db.query(Report).order_by(Report.created_at.desc()).all()
    return reports

@router.put("/reports/{report_id}")
def update_report_status(report_id: uuid.UUID, status: str, db: Session = Depends(get_db), current_admin = get_moderator_user):
    if status not in ["pending", "investigated", "resolved", "dismissed"]:
        raise HTTPException(status_code=400, detail="Invalid status")
        
    report = db.query(Report).filter(Report.id == report_id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
        
    report.status = status
    db.commit()
    return {"status": "success", "report_status": status}

@router.put("/users/{user_id}/verify", response_model=ProfileResponse)
def verify_user_profile(user_id: uuid.UUID, verification_status: str, db: Session = Depends(get_db), current_admin = get_moderator_user):
    if verification_status not in ["pending", "verified", "rejected"]:
        raise HTTPException(status_code=400, detail="Invalid verification status")
        
    profile = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
        
    profile.verification_status = verification_status
    
    # Also update verified flag on user credential model
    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.is_verified = (verification_status == "verified")
        
    db.commit()
    db.refresh(profile)
    return profile

@router.get("/waitlist", response_model=List[WaitlistResponse])
def get_waitlist_signups(db: Session = Depends(get_db), current_admin = get_moderator_user):
    waitlist = db.query(Waitlist).order_by(Waitlist.created_at.desc()).all()
    return waitlist
