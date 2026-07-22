from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Numeric, Float, Table, CheckConstraint, UniqueConstraint, ARRAY
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from datetime import datetime
from app.db.session import Base

# Association Table: Community Members
community_members = Table(
    'community_members',
    Base.metadata,
    Column('community_id', UUID(as_uuid=True), ForeignKey('communities.id', ondelete='CASCADE'), primary_key=True),
    Column('user_id', UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('role', String(50), default='member', nullable=False),
    Column('joined_at', DateTime(timezone=True), default=datetime.utcnow, nullable=False)
)

# Association Table: Chat Participants
chat_participants = Table(
    'chat_participants',
    Base.metadata,
    Column('room_id', UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), primary_key=True),
    Column('user_id', UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('joined_at', DateTime(timezone=True), default=datetime.utcnow, nullable=False)
)

# Association Table: Event RSVPs
event_rsvps = Table(
    'event_rsvps',
    Base.metadata,
    Column('event_id', UUID(as_uuid=True), ForeignKey('events.id', ondelete='CASCADE'), primary_key=True),
    Column('user_id', UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True),
    Column('status', String(50), default='going', nullable=False), # going, interested, cant_go
    Column('created_at', DateTime(timezone=True), default=datetime.utcnow, nullable=False)
)

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=True) # Nullable to support Google/Apple OAuth login
    phone = Column(String(50), nullable=True)
    role = Column(String(50), default='user', nullable=False) # user, moderator, admin
    is_verified = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    profile = relationship("Profile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    communities = relationship("Community", secondary=community_members, back_populates="members")
    posts = relationship("Post", back_populates="author", cascade="all, delete-orphan")
    comments = relationship("Comment", back_populates="author", cascade="all, delete-orphan")
    likes = relationship("Like", back_populates="user", cascade="all, delete-orphan")
    properties = relationship("Property", back_populates="owner", cascade="all, delete-orphan")
    events = relationship("Event", back_populates="organizer", cascade="all, delete-orphan")
    messages = relationship("Message", back_populates="sender", cascade="all, delete-orphan")
    chat_rooms = relationship("ChatRoom", secondary=chat_participants, back_populates="participants")

class Profile(Base):
    __tablename__ = "profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False)
    full_name = Column(String(100), nullable=False)
    age = Column(Integer, CheckConstraint('age >= 18 AND age <= 100'), nullable=True)
    gender = Column(String(20), nullable=True)
    occupation = Column(String(100), nullable=True) # student, professional, etc.
    college = Column(String(150), nullable=True)
    company = Column(String(150), nullable=True)
    languages = Column(ARRAY(String(100)), nullable=True)
    home_state = Column(String(100), nullable=True)
    home_city = Column(String(100), nullable=True)
    current_city = Column(String(100), nullable=True, index=True)
    budget_min = Column(Numeric(10, 2), default=0.00, nullable=False)
    budget_max = Column(Numeric(10, 2), nullable=False)
    bio = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)
    verification_status = Column(String(50), default='pending', nullable=False) # pending, verified, rejected
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="profile")
    lifestyle_preferences = relationship("LifestylePreference", back_populates="profile", uselist=False, cascade="all, delete-orphan")

class LifestylePreference(Base):
    __tablename__ = "lifestyle_preferences"

    profile_id = Column(UUID(as_uuid=True), ForeignKey('profiles.id', ondelete='CASCADE'), primary_key=True)
    food_pref = Column(String(50), default='any', nullable=False) # vegetarian, non-veg, vegan, any
    smoking = Column(Boolean, default=False, nullable=False)
    drinking = Column(String(50), default='socially', nullable=False) # never, socially, regularly
    pets = Column(String(50), default='no', nullable=False) # yes, no, friendly
    sleep_schedule = Column(String(50), default='flexible', nullable=False) # early, night_owl, flexible
    work_schedule = Column(String(50), default='flexible', nullable=False) # standard_9_5, night_shift, remote, flexible
    cleanliness_rating = Column(Integer, CheckConstraint('cleanliness_rating >= 1 AND cleanliness_rating <= 5'), default=3, nullable=False)
    interests = Column(ARRAY(String(100)), default=[], nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    profile = relationship("Profile", back_populates="lifestyle_preferences")

class Community(Base):
    __tablename__ = "communities"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(150), unique=True, nullable=False)
    slug = Column(String(150), unique=True, nullable=False)
    description = Column(String, nullable=True)
    category = Column(String(50), nullable=False, index=True) # city, college, language, state, profession, interest
    icon_url = Column(String, nullable=True)
    banner_url = Column(String, nullable=True)
    city_name = Column(String(100), nullable=True)
    member_count = Column(Integer, default=0, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    members = relationship("User", secondary=community_members, back_populates="communities")
    posts = relationship("Post", back_populates="community", cascade="all, delete-orphan")
    events = relationship("Event", back_populates="community", cascade="all, delete-orphan")

class Post(Base):
    __tablename__ = "posts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    community_id = Column(UUID(as_uuid=True), ForeignKey('communities.id', ondelete='CASCADE'), nullable=False, index=True)
    author_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    content = Column(String, nullable=False)
    media_urls = Column(ARRAY(String), default=[], nullable=False)
    is_pinned = Column(Boolean, default=False, nullable=False)
    is_announcement = Column(Boolean, default=False, nullable=False)
    likes_count = Column(Integer, default=0, nullable=False)
    comments_count = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, index=True, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    community = relationship("Community", back_populates="posts")
    author = relationship("User", back_populates="posts")
    comments = relationship("Comment", back_populates="post", cascade="all, delete-orphan")
    likes = relationship("Like", back_populates="post", cascade="all, delete-orphan")

class Comment(Base):
    __tablename__ = "comments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey('posts.id', ondelete='CASCADE'), nullable=False, index=True)
    author_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    content = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    post = relationship("Post", back_populates="comments")
    author = relationship("User", back_populates="comments")
    likes = relationship("Like", back_populates="comment", cascade="all, delete-orphan")

class Like(Base):
    __tablename__ = "likes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    post_id = Column(UUID(as_uuid=True), ForeignKey('posts.id', ondelete='CASCADE'), nullable=True)
    comment_id = Column(UUID(as_uuid=True), ForeignKey('comments.id', ondelete='CASCADE'), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    __table_args__ = (
        CheckConstraint(
            '(post_id IS NOT NULL AND comment_id IS NULL) OR (post_id IS NULL AND comment_id IS NOT NULL)',
            name='check_like_target'
        ),
        UniqueConstraint('user_id', 'post_id', name='unique_user_post_like'),
        UniqueConstraint('user_id', 'comment_id', name='unique_user_comment_like'),
    )

    user = relationship("User", back_populates="likes")
    post = relationship("Post", back_populates="likes")
    comment = relationship("Comment", back_populates="likes")

class RoommateMatch(Base):
    __tablename__ = "roommate_matches"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user1_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    user2_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    match_score = Column(Integer, CheckConstraint('match_score >= 0 AND match_score <= 100'), nullable=False)
    status = Column(String(50), default='pending', nullable=False) # pending, liked, disliked, matched
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    __table_args__ = (
        CheckConstraint('user1_id < user2_id', name='check_user_order'),
        UniqueConstraint('user1_id', 'user2_id', name='unique_roommate_match'),
    )

class ChatRoom(Base):
    __tablename__ = "chat_rooms"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    type = Column(String(50), default='direct', nullable=False) # direct, group
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    participants = relationship("User", secondary=chat_participants, back_populates="chat_rooms")
    messages = relationship("Message", back_populates="room", cascade="all, delete-orphan")

class Message(Base):
    __tablename__ = "messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    room_id = Column(UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), nullable=False, index=True)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    content = Column(String, nullable=False)
    media_url = Column(String, nullable=True)
    is_read = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, index=True, nullable=False)

    room = relationship("ChatRoom", back_populates="messages")
    sender = relationship("User", back_populates="messages")

class Property(Base):
    __tablename__ = "properties"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(String, nullable=False)
    price_per_month = Column(Numeric(10, 2), nullable=False)
    deposit = Column(Numeric(10, 2), nullable=False)
    address = Column(String, nullable=False)
    city = Column(String(100), nullable=False, index=True)
    location_lat = Column(Float, nullable=False)
    location_lng = Column(Float, nullable=False)
    room_type = Column(String(50), nullable=False) # single_room, shared_room, full_apartment, PG
    max_occupancy = Column(Integer, default=1, nullable=False)
    status = Column(String(50), default='available', nullable=False) # available, rented, archived
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    owner = relationship("User", back_populates="properties")
    images = relationship("PropertyImage", back_populates="property", cascade="all, delete-orphan")
    amenities = relationship("PropertyAmenity", back_populates="property", cascade="all, delete-orphan")
    bookmarks = relationship("Bookmark", back_populates="property", cascade="all, delete-orphan")

class PropertyImage(Base):
    __tablename__ = "property_images"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    property_id = Column(UUID(as_uuid=True), ForeignKey('properties.id', ondelete='CASCADE'), nullable=False)
    image_url = Column(String, nullable=False)
    display_order = Column(Integer, default=0, nullable=False)

    property = relationship("Property", back_populates="images")

class PropertyAmenity(Base):
    __tablename__ = "property_amenities"

    property_id = Column(UUID(as_uuid=True), ForeignKey('properties.id', ondelete='CASCADE'), primary_key=True)
    amenity_name = Column(String(100), primary_key=True, nullable=False)

    property = relationship("Property", back_populates="amenities")

class Bookmark(Base):
    __tablename__ = "bookmarks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    property_id = Column(UUID(as_uuid=True), ForeignKey('properties.id', ondelete='CASCADE'), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    __table_args__ = (
        UniqueConstraint('user_id', 'property_id', name='unique_user_property_bookmark'),
    )

    property = relationship("Property", back_populates="bookmarks")

class Event(Base):
    __tablename__ = "events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    community_id = Column(UUID(as_uuid=True), ForeignKey('communities.id', ondelete='CASCADE'), nullable=True, index=True)
    organizer_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(String, nullable=False)
    location_name = Column(String(255), nullable=False)
    lat = Column(Float, nullable=True)
    lng = Column(Float, nullable=True)
    start_time = Column(DateTime(timezone=True), nullable=False)
    rsvp_count = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    community = relationship("Community", back_populates="events")
    organizer = relationship("User", back_populates="events")

class Report(Base):
    __tablename__ = "reports"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    reporter_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    target_type = Column(String(50), nullable=False) # profile, community, post, property, message
    target_id = Column(UUID(as_uuid=True), nullable=False)
    reason = Column(String, nullable=False)
    status = Column(String(50), default='pending', nullable=False) # pending, investigated, resolved, dismissed
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

class Waitlist(Base):
    __tablename__ = "waitlist"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False)
    full_name = Column(String(100), nullable=False)
    current_city = Column(String(100), nullable=True)
    target_city = Column(String(100), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

# Centralized Notification System Models
class Notification(Base):
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    type = Column(String(50), nullable=False) # MATCH, MATCH_REQUEST, MESSAGE, VERIFICATION, SECURITY, SYSTEM
    title = Column(String(255), nullable=False)
    message = Column(String, nullable=False)
    is_read = Column(Boolean, default=False, nullable=False)
    related_entity_id = Column(String(255), nullable=True)
    deep_link = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    user = relationship("User", backref="notifications")

class DeviceToken(Base):
    __tablename__ = "device_tokens"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False, index=True)
    token = Column(String(500), nullable=False, unique=True)
    platform = Column(String(50), default='android', nullable=False) # android, ios, web
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", backref="device_tokens")

class NotificationPreference(Base):
    __tablename__ = "notification_preferences"

    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    email_enabled = Column(Boolean, default=True, nullable=False)
    push_enabled = Column(Boolean, default=True, nullable=False)
    match_alerts = Column(Boolean, default=True, nullable=False)
    message_alerts = Column(Boolean, default=True, nullable=False)
    verification_alerts = Column(Boolean, default=True, nullable=False)
    system_alerts = Column(Boolean, default=True, nullable=False) # Security / System alerts cannot be disabled
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", backref="notification_preference")
