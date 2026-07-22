from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional, Any
from uuid import UUID
from datetime import datetime
from decimal import Decimal

# Token Schemas
class Token(BaseModel):
    access_token: str
    token_type: str
    refresh_token: str
    user_id: UUID
    role: str

class TokenData(BaseModel):
    user_id: Optional[str] = None
    role: Optional[str] = None

class RefreshTokenRequest(BaseModel):
    refresh_token: str

# Waitlist Schemas
class WaitlistCreate(BaseModel):
    email: EmailStr
    full_name: str
    current_city: Optional[str] = ""
    target_city: str

class WaitlistResponse(BaseModel):
    id: UUID
    email: EmailStr
    full_name: str
    current_city: Optional[str] = ""
    target_city: str
    created_at: datetime

    class Config:
        from_attributes = True

# User & Auth Schemas
class UserSignup(BaseModel):
    email: EmailStr
    password: str
    phone: Optional[str] = None
    role: Optional[str] = "user" # user, owner, moderator, admin

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: UUID
    email: EmailStr
    phone: Optional[str] = None
    role: str
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True

# Verification & OTP Schemas
class OTPRequest(BaseModel):
    email: EmailStr

class OTPVerify(BaseModel):
    email: EmailStr
    code: str

class IdentityVerifyRequest(BaseModel):
    document_type: str # student_id, govt_id, passport
    id_number: str
    college_or_company: Optional[str] = None

# Lifestyle Preferences Schemas
class LifestylePreferenceSchema(BaseModel):
    food_pref: str = "any"
    smoking: bool = False
    drinking: str = "socially"
    pets: str = "no"
    sleep_schedule: str = "flexible"
    work_schedule: str = "flexible"
    cleanliness_rating: int = 3
    interests: List[str] = []

    class Config:
        from_attributes = True

# Profile Schemas
class ProfileCreate(BaseModel):
    full_name: str
    age: Optional[int] = None
    gender: Optional[str] = None
    occupation: Optional[str] = None
    college: Optional[str] = None
    company: Optional[str] = None
    languages: Optional[List[str]] = []
    home_state: Optional[str] = None
    home_city: Optional[str] = None
    current_city: Optional[str] = None
    budget_min: Decimal = Decimal("0.00")
    budget_max: Decimal
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    lifestyle: Optional[LifestylePreferenceSchema] = None

class ProfileResponse(BaseModel):
    id: UUID
    user_id: UUID
    full_name: str
    age: Optional[int] = None
    gender: Optional[str] = None
    occupation: Optional[str] = None
    college: Optional[str] = None
    company: Optional[str] = None
    languages: Optional[List[str]] = []
    home_state: Optional[str] = None
    home_city: Optional[str] = None
    current_city: Optional[str] = None
    budget_min: Decimal
    budget_max: Decimal
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    verification_status: str
    lifestyle_preferences: Optional[LifestylePreferenceSchema] = None

    class Config:
        from_attributes = True

# Community Schemas
class CommunityCreate(BaseModel):
    name: str
    slug: str
    description: Optional[str] = None
    category: str
    icon_url: Optional[str] = None
    banner_url: Optional[str] = None
    city_name: Optional[str] = None

class CommunityResponse(BaseModel):
    id: UUID
    name: str
    slug: str
    description: Optional[str] = None
    category: str
    icon_url: Optional[str] = None
    banner_url: Optional[str] = None
    city_name: Optional[str] = None
    member_count: int
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True

# Post & Comment Schemas
class PostCreate(BaseModel):
    content: str
    media_urls: Optional[List[str]] = []
    is_pinned: Optional[bool] = False
    is_announcement: Optional[bool] = False

class PostResponse(BaseModel):
    id: UUID
    community_id: UUID
    author_id: UUID
    author_name: Optional[str] = None
    author_avatar: Optional[str] = None
    content: str
    media_urls: List[str]
    is_pinned: bool
    is_announcement: bool
    likes_count: int
    comments_count: int
    is_liked_by_me: Optional[bool] = False
    created_at: datetime

    class Config:
        from_attributes = True

class CommentCreate(BaseModel):
    content: str

class CommentResponse(BaseModel):
    id: UUID
    post_id: UUID
    author_id: UUID
    author_name: Optional[str] = None
    author_avatar: Optional[str] = None
    content: str
    created_at: datetime

    class Config:
        from_attributes = True

# Housing & Amenities Schemas
class AmenitySchema(BaseModel):
    amenity_name: str

class ImageSchema(BaseModel):
    image_url: str
    display_order: int

class PropertyCreate(BaseModel):
    title: str
    description: str
    price_per_month: Decimal
    deposit: Decimal
    address: str
    city: str
    location_lat: float
    location_lng: float
    room_type: str
    max_occupancy: int
    amenities: List[str] = []
    images: List[str] = []

class PropertyResponse(BaseModel):
    id: UUID
    owner_id: UUID
    title: str
    description: str
    price_per_month: Decimal
    deposit: Decimal
    address: str
    city: str
    location_lat: float
    location_lng: float
    room_type: str
    max_occupancy: int
    status: str
    created_at: datetime
    images: List[ImageSchema] = []
    amenities: List[AmenitySchema] = []
    is_bookmarked: Optional[bool] = False

    class Config:
        from_attributes = True

# Chat & Messages Schemas
class MessageCreate(BaseModel):
    content: str
    media_url: Optional[str] = None

class MessageResponse(BaseModel):
    id: UUID
    room_id: UUID
    sender_id: UUID
    content: str
    media_url: Optional[str] = None
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True

class ChatRoomResponse(BaseModel):
    id: UUID
    type: str
    created_at: datetime
    recipient_name: Optional[str] = None
    recipient_avatar: Optional[str] = None
    last_message: Optional[str] = None
    last_message_time: Optional[datetime] = None

    class Config:
        from_attributes = True

# Roommate Match Swipe Schemas
class RoommateMatchResponse(BaseModel):
    id: UUID
    user_profile: ProfileResponse
    match_score: int
    status: str
    matching_tags: List[str] = []
    summary: str

# Relocation AI Assistant Schemas
class RelocationQuery(BaseModel):
    current_city: str
    target_city: str
    budget: float
    preferences: List[str] = []

# Event Schemas
class EventCreate(BaseModel):
    title: str
    description: str
    location_name: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    start_time: datetime

class EventResponse(BaseModel):
    id: UUID
    community_id: Optional[UUID] = None
    organizer_id: UUID
    title: str
    description: str
    location_name: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    start_time: datetime
    rsvp_count: int
    my_rsvp_status: Optional[str] = None # going, interested, cant_go, null
    created_at: datetime

    class Config:
        from_attributes = True

# Moderator Reports Schemas
class ReportCreate(BaseModel):
    target_type: str
    target_id: UUID
    reason: str

class ReportResponse(BaseModel):
    id: UUID
    reporter_id: UUID
    target_type: str
    target_id: UUID
    reason: str
    status: str
    created_at: datetime

    class Config:
        from_attributes = True
