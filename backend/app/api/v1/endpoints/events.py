from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, select
from app.db.session import get_db
from app.models.models import User, Event, event_rsvps
from app.schemas.schemas import EventResponse, EventCreate
from app.api.deps import get_current_user
from typing import List, Optional
import uuid

router = APIRouter()

def serialize_event(event: Event, db: Session, current_user_id: Optional[uuid.UUID] = None) -> EventResponse:
    my_rsvp = None
    if current_user_id:
        stmt = select(event_rsvps.c.status).where(
            and_(event_rsvps.c.event_id == event.id, event_rsvps.c.user_id == current_user_id)
        )
        my_rsvp = db.execute(stmt).scalar()
        
    return EventResponse(
        id=event.id,
        community_id=event.community_id,
        organizer_id=event.organizer_id,
        title=event.title,
        description=event.description,
        location_name=event.location_name,
        lat=event.lat,
        lng=event.lng,
        start_time=event.start_time,
        rsvp_count=event.rsvp_count,
        my_rsvp_status=my_rsvp,
        created_at=event.created_at
    )

@router.get("/", response_model=List[EventResponse])
def get_events(community_id: Optional[uuid.UUID] = None, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    query = db.query(Event)
    if community_id:
        query = query.filter(Event.community_id == community_id)
    events = query.order_by(Event.start_time.asc()).all()
    return [serialize_event(e, db, current_user.id) for e in events]

@router.post("/", response_model=EventResponse)
def create_event(data: EventCreate, community_id: Optional[uuid.UUID] = None, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    event = Event(
        community_id=community_id,
        organizer_id=current_user.id,
        title=data.title,
        description=data.description,
        location_name=data.location_name,
        lat=data.lat,
        lng=data.lng,
        start_time=data.start_time,
        rsvp_count=0
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return serialize_event(event, db, current_user.id)

@router.post("/{event_id}/rsvp")
def rsvp_to_event(event_id: uuid.UUID, status: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if status not in ["going", "interested", "cant_go"]:
        raise HTTPException(status_code=400, detail="Invalid RSVP status, must be 'going', 'interested', or 'cant_go'")

    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")

    stmt = select(event_rsvps).where(
        and_(event_rsvps.c.event_id == event_id, event_rsvps.c.user_id == current_user.id)
    )
    existing = db.execute(stmt).first()

    if existing:
        # Update existing RSVP
        update_stmt = event_rsvps.update().where(
            and_(event_rsvps.c.event_id == event_id, event_rsvps.c.user_id == current_user.id)
        ).values(status=status)
        db.execute(update_stmt)
        
        # Adjust counts
        if existing.status != "going" and status == "going":
            event.rsvp_count += 1
        elif existing.status == "going" and status != "going":
            event.rsvp_count = max(0, event.rsvp_count - 1)
    else:
        # Create new RSVP
        insert_stmt = event_rsvps.insert().values(
            event_id=event_id,
            user_id=current_user.id,
            status=status
        )
        db.execute(insert_stmt)
        if status == "going":
            event.rsvp_count += 1
            
    db.commit()
    return {"status": "success", "rsvp_status": status, "rsvp_count": event.rsvp_count}
