from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from app.db.session import get_db
from app.models.models import User, Profile, LifestylePreference, RoommateMatch, ChatRoom, chat_participants
from app.schemas.schemas import RoommateMatchResponse, ProfileResponse, LifestylePreferenceSchema
from app.services.roommate_algorithm import RoommateMatcher
from app.api.deps import get_current_user
import uuid

router = APIRouter()

def serialize_lifestyle(lifestyle: LifestylePreference) -> LifestylePreferenceSchema:
    if not lifestyle:
        return LifestylePreferenceSchema()
    return LifestylePreferenceSchema(
        food_pref=lifestyle.food_pref,
        smoking=lifestyle.smoking,
        drinking=lifestyle.drinking,
        pets=lifestyle.pets,
        sleep_schedule=lifestyle.sleep_schedule,
        work_schedule=lifestyle.work_schedule,
        cleanliness_rating=lifestyle.cleanliness_rating,
        interests=lifestyle.interests
    )

def serialize_profile(profile: Profile, lifestyle: LifestylePreference) -> ProfileResponse:
    return ProfileResponse(
        id=profile.id,
        user_id=profile.user_id,
        full_name=profile.full_name,
        age=profile.age,
        gender=profile.gender,
        occupation=profile.occupation,
        college=profile.college,
        company=profile.company,
        languages=profile.languages,
        home_state=profile.home_state,
        home_city=profile.home_city,
        current_city=profile.current_city,
        budget_min=profile.budget_min,
        budget_max=profile.budget_max,
        bio=profile.bio,
        avatar_url=profile.avatar_url,
        verification_status=profile.verification_status,
        lifestyle_preferences=serialize_lifestyle(lifestyle)
    )

@router.get("/recommendations", response_model=list[RoommateMatchResponse])
def get_roommate_recommendations(
    current_user: User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    my_profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not my_profile:
        raise HTTPException(status_code=404, detail="Please complete onboarding first")
    
    my_lifestyle = db.query(LifestylePreference).filter(LifestylePreference.profile_id == my_profile.id).first()
    my_dict = {
        "budget_min": my_profile.budget_min,
        "budget_max": my_profile.budget_max,
        "cleanliness_rating": my_lifestyle.cleanliness_rating if my_lifestyle else 3,
        "sleep_schedule": my_lifestyle.sleep_schedule if my_lifestyle else "flexible",
        "work_schedule": my_lifestyle.work_schedule if my_lifestyle else "flexible",
        "smoking": my_lifestyle.smoking if my_lifestyle else False,
        "drinking": my_lifestyle.drinking if my_lifestyle else "socially",
        "pets": my_lifestyle.pets if my_lifestyle else "no",
        "food_pref": my_lifestyle.food_pref if my_lifestyle else "any",
        "interests": my_lifestyle.interests if my_lifestyle else [],
        "home_state": my_profile.home_state
    }

    # Query other profiles
    other_profiles = db.query(Profile).filter(Profile.user_id != current_user.id).all()
    
    results = []
    for other_p in other_profiles:
        other_lifestyle = db.query(LifestylePreference).filter(LifestylePreference.profile_id == other_p.id).first()
        other_dict = {
            "budget_min": other_p.budget_min,
            "budget_max": other_p.budget_max,
            "cleanliness_rating": other_lifestyle.cleanliness_rating if other_lifestyle else 3,
            "sleep_schedule": other_lifestyle.sleep_schedule if other_lifestyle else "flexible",
            "work_schedule": other_lifestyle.work_schedule if other_lifestyle else "flexible",
            "smoking": other_lifestyle.smoking if other_lifestyle else False,
            "drinking": other_lifestyle.drinking if other_lifestyle else "socially",
            "pets": other_lifestyle.pets if other_lifestyle else "no",
            "food_pref": other_lifestyle.food_pref if other_lifestyle else "any",
            "interests": other_lifestyle.interests if other_lifestyle else [],
            "home_state": other_p.home_state
        }
        
        breakdown = RoommateMatcher.get_compatibility_breakdown(my_dict, other_dict)
        
        # Check if swipe matches exist
        u1, u2 = min(current_user.id, other_p.user_id), max(current_user.id, other_p.user_id)
        match = db.query(RoommateMatch).filter(and_(RoommateMatch.user1_id == u1, RoommateMatch.user2_id == u2)).first()
        status = match.status if match else "pending"
        
        # Skip if already disliked
        if status == "disliked":
            continue
            
        results.append(RoommateMatchResponse(
            id=other_p.id,
            user_profile=serialize_profile(other_p, other_lifestyle),
            match_score=breakdown["match_score"],
            status=status,
            matching_tags=breakdown["matching_tags"],
            summary=breakdown["summary"]
        ))
        
    results.sort(key=lambda x: x.match_score, reverse=True)
    return results

@router.post("/swipe")
def swipe_roommate(
    target_user_id: uuid.UUID, 
    action: str, # liked, disliked
    current_user: User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    if action not in ["liked", "disliked"]:
        raise HTTPException(status_code=400, detail="Invalid action, must be 'liked' or 'disliked'")

    u1, u2 = min(current_user.id, target_user_id), max(current_user.id, target_user_id)
    
    # Calculate score
    my_p = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    my_l = db.query(LifestylePreference).filter(LifestylePreference.profile_id == my_p.id).first() if my_p else None
    
    target_p = db.query(Profile).filter(Profile.user_id == target_user_id).first()
    target_l = db.query(LifestylePreference).filter(LifestylePreference.profile_id == target_p.id).first() if target_p else None
    
    score = 50 # default
    if my_p and target_p and my_l and target_l:
        my_dict = {"budget_min": my_p.budget_min, "budget_max": my_p.budget_max, "cleanliness_rating": my_l.cleanliness_rating, "sleep_schedule": my_l.sleep_schedule, "work_schedule": my_l.work_schedule, "smoking": my_l.smoking, "drinking": my_l.drinking, "pets": my_l.pets, "food_pref": my_l.food_pref, "interests": my_l.interests, "home_state": my_p.home_state}
        target_dict = {"budget_min": target_p.budget_min, "budget_max": target_p.budget_max, "cleanliness_rating": target_l.cleanliness_rating, "sleep_schedule": target_l.sleep_schedule, "work_schedule": target_l.work_schedule, "smoking": target_l.smoking, "drinking": target_l.drinking, "pets": target_l.pets, "food_pref": target_l.food_pref, "interests": target_l.interests, "home_state": target_p.home_state}
        score = RoommateMatcher.calculate_compatibility(my_dict, target_dict)

    match = db.query(RoommateMatch).filter(and_(RoommateMatch.user1_id == u1, RoommateMatch.user2_id == u2)).first()
    
    if not match:
        # Create match placeholder
        # Status logic: if swiped liked, we set pending/liked from user1/user2 perspective.
        # But to keep it simple, we record who swiped:
        # Let's save a state in match table
        match = RoommateMatch(
            user1_id=u1,
            user2_id=u2,
            match_score=score,
            status=action
        )
        db.add(match)
        db.commit()
        return {"status": action, "is_match": False}
    
    if action == "disliked":
        match.status = "disliked"
        db.commit()
        return {"status": "disliked", "is_match": False}
        
    # If action is 'liked' and a match already exists
    # If the match was swiped "liked" by the other person first, it becomes "matched"
    if match.status == "liked":
        match.status = "matched"
        
        # Create Chat Room automatically
        chat_room = ChatRoom(type="direct")
        db.add(chat_room)
        db.flush()
        
        # Add participants
        db.execute(chat_participants.insert().values(room_id=chat_room.id, user_id=current_user.id))
        db.execute(chat_participants.insert().values(room_id=chat_room.id, user_id=target_user_id))
        
        db.commit()
        return {"status": "matched", "is_match": True, "room_id": chat_room.id}
    else:
        # If it was pending or something else, update to liked
        match.status = "liked"
        db.commit()
        return {"status": "liked", "is_match": False}
