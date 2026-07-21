from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

from app.core.config import settings
from app.services.roommate_algorithm import RoommateMatcher
from app.services.ai_gemini import GeminiRelocationAssistant

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Set CORS origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize AI Assistant
ai_assistant = GeminiRelocationAssistant()

# Temporary In-Memory Database for demonstration & testing
WAITLIST_DB = []
COMMUNITIES_DB = [
    {
        "id": "1",
        "name": "Bangalore Techies & Interns",
        "slug": "blr-tech",
        "description": "The official community for devs, interns, and builders relocating to Bangalore.",
        "category": "city",
        "icon_url": "https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=150&q=80",
        "member_count": 1420,
        "is_verified": True
    },
    {
        "id": "2",
        "name": "Kannada Language & Culture Club",
        "slug": "kannada-club",
        "description": "Learn basic Kannada, explore native spots, and mingle with locals.",
        "category": "language",
        "icon_url": "https://images.unsplash.com/photo-1608958416719-f81d11ca72aa?auto=format&fit=crop&w=150&q=80",
        "member_count": 480,
        "is_verified": False
    },
    {
        "id": "3",
        "name": "PES University Relocation Hub",
        "slug": "pes-hub",
        "description": "PES alumni, freshmen, and seniors connecting for housing and roommates.",
        "category": "college",
        "icon_url": "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=150&q=80",
        "member_count": 890,
        "is_verified": True
    }
]

PROFILES_DB = [
    {
        "id": "u1",
        "full_name": "Rohan Sharma",
        "age": 22,
        "gender": "Male",
        "occupation": "Software Engineer Intern",
        "college": "BITS Pilani",
        "company": "Google",
        "home_city": "Delhi",
        "current_city": "Bangalore",
        "budget_min": 8000,
        "budget_max": 15000,
        "cleanliness_rating": 4,
        "sleep_schedule": "night_owl",
        "work_schedule": "flexible",
        "smoking": False,
        "drinking": "socially",
        "pets": "no",
        "food_pref": "vegetarian",
        "interests": ["Coding", "Gaming", "Football"],
        "bio": "Moving to Bangalore for my summer internship. Looking for a neat flatmate who is chill with late-night gaming.",
        "avatar_url": "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=150&q=80"
    },
    {
        "id": "u2",
        "full_name": "Aanya Iyer",
        "age": 23,
        "gender": "Female",
        "occupation": "Data Analyst",
        "college": "SRM University",
        "company": "Amazon",
        "home_city": "Chennai",
        "current_city": "Bangalore",
        "budget_min": 10000,
        "budget_max": 18000,
        "cleanliness_rating": 5,
        "sleep_schedule": "early",
        "work_schedule": "standard_9_5",
        "smoking": False,
        "drinking": "never",
        "pets": "yes",
        "food_pref": "any",
        "interests": ["Music", "Reading", "Hiking"],
        "bio": "Joining Amazon full-time. Extremely clean and organized. I love pets and cooking!",
        "avatar_url": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80"
    }
]

# Pydantic Schemas
class WaitlistCreate(BaseModel):
    email: EmailStr
    full_name: str
    current_city: Optional[str] = ""
    target_city: str

class WaitlistResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    target_city: str
    created_at: str

class ProfileCreate(BaseModel):
    full_name: str
    age: int
    gender: str
    occupation: str
    college: Optional[str] = None
    company: Optional[str] = None
    home_city: str
    current_city: str
    budget_min: float
    budget_max: float
    cleanliness_rating: int
    sleep_schedule: str
    work_schedule: str
    smoking: bool
    drinking: str
    pets: str
    food_pref: str
    interests: List[str]
    bio: str
    avatar_url: Optional[str] = None

class RelocationQuery(BaseModel):
    current_city: str
    target_city: str
    budget: float
    preferences: List[str] = []

@app.get("/")
def read_root():
    return {
        "status": "online",
        "project": settings.PROJECT_NAME,
        "tagline": "Find Your People. Find Your Place."
    }

# WAITLIST ROUTER
@app.post(f"{settings.API_V1_STR}/waitlist", response_model=WaitlistResponse)
def add_to_waitlist(item: WaitlistCreate):
    # Check duplicate
    for w in WAITLIST_DB:
        if w["email"] == item.email:
            raise HTTPException(status_code=400, detail="Email already registered in waitlist")
    
    new_id = str(uuid.uuid4())
    created_at = datetime.utcnow().isoformat()
    waitlist_entry = {
        "id": new_id,
        "email": item.email,
        "full_name": item.full_name,
        "current_city": item.current_city,
        "target_city": item.target_city,
        "created_at": created_at
    }
    WAITLIST_DB.append(waitlist_entry)
    return waitlist_entry

@app.get(f"{settings.API_V1_STR}/waitlist", response_model=List[WaitlistResponse])
def get_waitlist():
    return WAITLIST_DB

# COMMUNITIES ROUTER
@app.get(f"{settings.API_V1_STR}/communities")
def list_communities(category: Optional[str] = None):
    if category:
        return [c for c in COMMUNITIES_DB if c["category"] == category]
    return COMMUNITIES_DB

# ROOMMATE MATCHING ROUTER
@app.post(f"{settings.API_V1_STR}/roommates/match")
def match_roommate(profile: ProfileCreate):
    matches = []
    p1_dict = profile.model_dump()
    for other_p in PROFILES_DB:
        breakdown = RoommateMatcher.get_compatibility_breakdown(p1_dict, other_p)
        matches.append({
            "profile": other_p,
            "match_details": breakdown
        })
    # Sort by score descending
    matches.sort(key=lambda x: x["match_details"]["match_score"], reverse=True)
    return matches

# AI RELOCATION ASSISTANT ROUTER
@app.post(f"{settings.API_V1_STR}/relocation/assistant")
def relocation_assistant(query: RelocationQuery):
    advice = ai_assistant.get_relocation_advice(
        current_city=query.current_city,
        target_city=query.target_city,
        budget=query.budget,
        preferences=query.preferences
    )
    return {"advice": advice}

@app.get(f"{settings.API_V1_STR}/search/parse")
def parse_search(query: str):
    parsed = ai_assistant.parse_natural_language_search(query)
    return parsed
