from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.models import Waitlist
from app.schemas.schemas import WaitlistCreate, WaitlistResponse
from typing import List

router = APIRouter()

@router.post("/", response_model=WaitlistResponse)
def add_to_waitlist(data: WaitlistCreate, db: Session = Depends(get_db)):
    existing = db.query(Waitlist).filter(Waitlist.email == data.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This email address is already on our waitlist. Stay tuned!"
        )
    
    entry = Waitlist(
        email=data.email,
        full_name=data.full_name,
        current_city=data.current_city,
        target_city=data.target_city
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry

@router.get("/", response_model=List[WaitlistResponse])
def list_waitlist(db: Session = Depends(get_db)):
    # Publicly accessible for preview/landing stats, ordered by newest
    return db.query(Waitlist).order_by(Waitlist.created_at.desc()).all()
