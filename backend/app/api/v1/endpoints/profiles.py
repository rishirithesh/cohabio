from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.models import User, Profile, LifestylePreference
from app.schemas.schemas import ProfileCreate, ProfileResponse, LifestylePreferenceSchema
from app.api.deps import get_current_user
import uuid

router = APIRouter()

@router.get("/me", response_model=ProfileResponse)
def get_my_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    # Pre-fetch lifestyle preferences
    lifestyle = db.query(LifestylePreference).filter(LifestylePreference.profile_id == profile.id).first()
    if lifestyle:
        profile.lifestyle_preferences = lifestyle
    return profile

@router.put("/me", response_model=ProfileResponse)
def update_my_profile(
    data: ProfileCreate, 
    current_user: User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        profile = Profile(user_id=current_user.id, full_name=data.full_name, budget_max=data.budget_max)
        db.add(profile)
        db.flush()

    profile.full_name = data.full_name
    profile.age = data.age
    profile.gender = data.gender
    profile.occupation = data.occupation
    profile.college = data.college
    profile.company = data.company
    profile.languages = data.languages
    profile.home_state = data.home_state
    profile.home_city = data.home_city
    profile.current_city = data.current_city
    profile.budget_min = data.budget_min
    profile.budget_max = data.budget_max
    profile.bio = data.bio
    profile.avatar_url = data.avatar_url

    if data.lifestyle:
        lifestyle = db.query(LifestylePreference).filter(LifestylePreference.profile_id == profile.id).first()
        if not lifestyle:
            lifestyle = LifestylePreference(profile_id=profile.id)
            db.add(lifestyle)
        
        lifestyle.food_pref = data.lifestyle.food_pref
        lifestyle.smoking = data.lifestyle.smoking
        lifestyle.drinking = data.lifestyle.drinking
        lifestyle.pets = data.lifestyle.pets
        lifestyle.sleep_schedule = data.lifestyle.sleep_schedule
        lifestyle.work_schedule = data.lifestyle.work_schedule
        lifestyle.cleanliness_rating = data.lifestyle.cleanliness_rating
        lifestyle.interests = data.lifestyle.interests

    db.commit()
    db.refresh(profile)
    
    # Return profile with preloaded lifestyle preferences
    lifestyle = db.query(LifestylePreference).filter(LifestylePreference.profile_id == profile.id).first()
    if lifestyle:
        profile.lifestyle_preferences = lifestyle
    return profile

@router.get("/{user_id}", response_model=ProfileResponse)
def get_user_profile(user_id: uuid.UUID, db: Session = Depends(get_db)):
    profile = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    lifestyle = db.query(LifestylePreference).filter(LifestylePreference.profile_id == profile.id).first()
    if lifestyle:
        profile.lifestyle_preferences = lifestyle
    return profile
