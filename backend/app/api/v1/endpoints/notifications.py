from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.models import User, Notification, DeviceToken, NotificationPreference
from app.api.deps import get_current_user
from app.services.notification_service import NotificationService
from pydantic import BaseModel
from typing import List, Optional
import uuid

router = APIRouter()

class DeviceTokenRequest(BaseModel):
    token: str
    platform: Optional[str] = "android"

class NotificationPreferenceSchema(BaseModel):
    email_enabled: bool = True
    push_enabled: bool = True
    match_alerts: bool = True
    message_alerts: bool = True
    verification_alerts: bool = True

class TestNotificationRequest(BaseModel):
    type: str = "MATCH" # MATCH, MESSAGE, VERIFICATION, SECURITY, SYSTEM
    title: str = "Test Notification"
    message: str = "This is a test notification sent from CoHabio Notification System!"

@router.get("")
def get_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    notifications = db.query(Notification).filter(
        Notification.user_id == current_user.id
    ).order_by(Notification.created_at.desc()).limit(50).all()

    unread_count = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).count()

    return {
        "unread_count": unread_count,
        "notifications": [
            {
                "id": str(n.id),
                "type": n.type,
                "title": n.title,
                "message": n.message,
                "is_read": n.is_read,
                "related_entity_id": n.related_entity_id,
                "deep_link": n.deep_link,
                "created_at": n.created_at.isoformat()
            }
            for n in notifications
        ]
    }

@router.post("/{notification_id}/read")
def mark_read(
    notification_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    n = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()
    if not n:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    n.is_read = True
    db.commit()
    return {"status": "ok", "message": "Notification marked as read"}

@router.post("/read-all")
def mark_all_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({"is_read": True})
    db.commit()
    return {"status": "ok", "message": "All notifications marked as read"}

@router.post("/device-token")
def register_device_token(
    req: DeviceTokenRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    existing = db.query(DeviceToken).filter(DeviceToken.token == req.token).first()
    if existing:
        existing.user_id = current_user.id
        existing.is_active = True
        existing.platform = req.platform
    else:
        dev_token = DeviceToken(
            id=uuid.uuid4(),
            user_id=current_user.id,
            token=req.token,
            platform=req.platform,
            is_active=True
        )
        db.add(dev_token)
    db.commit()
    return {"status": "ok", "message": "Device push token registered successfully"}

@router.get("/preferences")
def get_preferences(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    prefs = db.query(NotificationPreference).filter(NotificationPreference.user_id == current_user.id).first()
    if not prefs:
        prefs = NotificationPreference(user_id=current_user.id)
        db.add(prefs)
        db.commit()
        db.refresh(prefs)
    return {
        "email_enabled": prefs.email_enabled,
        "push_enabled": prefs.push_enabled,
        "match_alerts": prefs.match_alerts,
        "message_alerts": prefs.message_alerts,
        "verification_alerts": prefs.verification_alerts,
        "system_alerts": prefs.system_alerts
    }

@router.put("/preferences")
def update_preferences(
    req: NotificationPreferenceSchema,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    prefs = db.query(NotificationPreference).filter(NotificationPreference.user_id == current_user.id).first()
    if not prefs:
        prefs = NotificationPreference(user_id=current_user.id)
        db.add(prefs)

    prefs.email_enabled = req.email_enabled
    prefs.push_enabled = req.push_enabled
    prefs.match_alerts = req.match_alerts
    prefs.message_alerts = req.message_alerts
    prefs.verification_alerts = req.verification_alerts
    db.commit()
    return {"status": "ok", "message": "Notification preferences updated"}

@router.post("/test")
def trigger_test_notification(
    req: TestNotificationRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Development test endpoint to trigger a notification across all channels."""
    n = NotificationService.dispatch_notification(
        db=db,
        user_id=current_user.id,
        type_=req.type,
        title=req.title,
        message=req.message,
        deep_link="/notifications"
    )
    return {"status": "ok", "message": "Test notification dispatched!", "notification_id": str(n.id)}
