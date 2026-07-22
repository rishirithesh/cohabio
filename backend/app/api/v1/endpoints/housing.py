from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, exists
from app.db.session import get_db
from app.models.models import User, Property, PropertyImage, PropertyAmenity, Bookmark
from app.schemas.schemas import PropertyResponse, PropertyCreate, ImageSchema, AmenitySchema
from app.api.deps import get_current_user
from typing import List, Optional
from decimal import Decimal
import uuid

router = APIRouter()

def serialize_property(prop: Property, db: Session, current_user_id: Optional[uuid.UUID] = None) -> PropertyResponse:
    images = db.query(PropertyImage).filter(PropertyImage.property_id == prop.id).order_by(PropertyImage.display_order.asc()).all()
    amenities = db.query(PropertyAmenity).filter(PropertyAmenity.property_id == prop.id).all()
    
    is_bookmarked = False
    if current_user_id:
        is_bookmarked = db.query(exists().where(and_(Bookmark.user_id == current_user_id, Bookmark.property_id == prop.id))).scalar()

    return PropertyResponse(
        id=prop.id,
        owner_id=prop.owner_id,
        title=prop.title,
        description=prop.description,
        price_per_month=prop.price_per_month,
        deposit=prop.deposit,
        address=prop.address,
        city=prop.city,
        location_lat=prop.location_lat,
        location_lng=prop.location_lng,
        room_type=prop.room_type,
        max_occupancy=prop.max_occupancy,
        status=prop.status,
        created_at=prop.created_at,
        images=[ImageSchema(image_url=img.image_url, display_order=img.display_order) for img in images],
        amenities=[AmenitySchema(amenity_name=a.amenity_name) for a in amenities],
        is_bookmarked=is_bookmarked
    )

@router.get("/", response_model=List[PropertyResponse])
def get_properties(
    city: Optional[str] = None,
    room_type: Optional[str] = None,
    price_min: Optional[float] = None,
    price_max: Optional[float] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Property).filter(Property.status == "available")
    if city:
        query = query.filter(Property.city.ilike(f"%{city}%"))
    if room_type:
        query = query.filter(Property.room_type == room_type)
    if price_min is not None:
        query = query.filter(Property.price_per_month >= price_min)
    if price_max is not None:
        query = query.filter(Property.price_per_month <= price_max)
        
    properties = query.all()
    return [serialize_property(p, db, current_user.id) for p in properties]

@router.post("/", response_model=PropertyResponse)
def create_property(
    data: PropertyCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Enforce admin, mod, or owner role to publish listings
    if current_user.role not in ["admin", "moderator", "owner"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only property owners or moderators can create listings."
        )

    prop = Property(
        owner_id=current_user.id,
        title=data.title,
        description=data.description,
        price_per_month=data.price_per_month,
        deposit=data.deposit,
        address=data.address,
        city=data.city,
        location_lat=data.location_lat,
        location_lng=data.location_lng,
        room_type=data.room_type,
        max_occupancy=data.max_occupancy,
        status="available"
    )
    db.add(prop)
    db.flush()

    # Add amenities
    for idx, amenity in enumerate(data.amenities):
        db.add(PropertyAmenity(property_id=prop.id, amenity_name=amenity))
    
    # Add images
    for idx, img_url in enumerate(data.images):
        db.add(PropertyImage(property_id=prop.id, image_url=img_url, display_order=idx))

    db.commit()
    db.refresh(prop)
    return serialize_property(prop, db, current_user.id)

@router.post("/{property_id}/bookmark")
def toggle_bookmark(
    property_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    prop = db.query(Property).filter(Property.id == property_id).first()
    if not prop:
        raise HTTPException(status_code=404, detail="Property listing not found")

    existing = db.query(Bookmark).filter(and_(Bookmark.user_id == current_user.id, Bookmark.property_id == property_id)).first()
    if existing:
        db.delete(existing)
        db.commit()
        return {"status": "unbookmarked"}
    else:
        bk = Bookmark(user_id=current_user.id, property_id=property_id)
        db.add(bk)
        db.commit()
        return {"status": "bookmarked"}

@router.get("/bookmarks", response_model=List[PropertyResponse])
def get_my_bookmarks(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    bookmarks = db.query(Bookmark).filter(Bookmark.user_id == current_user.id).all()
    prop_ids = [bk.property_id for bk in bookmarks]
    properties = db.query(Property).filter(Property.id.in_(prop_ids)).all()
    return [serialize_property(p, db, current_user.id) for p in properties]
