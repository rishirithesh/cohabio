import logging
from sqlalchemy.orm import Session
from app.models.models import Notification, DeviceToken, NotificationPreference, User
from app.services.email_service import EmailService
from typing import Optional, List, Dict, Any
import uuid

logger = logging.getLogger(__name__)

class NotificationService:
    """
    Centralized Notification Engine for CoHabio.
    Dispatches notifications across In-App, Email (SMTP), and Mobile Push channels.
    """

    @staticmethod
    def dispatch_notification(
        db: Session,
        user_id: uuid.UUID,
        type_: str,
        title: str,
        message: str,
        related_entity_id: Optional[str] = None,
        deep_link: Optional[str] = None,
        email_template: Optional[str] = None
    ) -> Notification:
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            logger.warning(f"Cannot dispatch notification: User {user_id} not found.")
            return None

        # 1. Create & Save In-App Notification Record
        notification = Notification(
            id=uuid.uuid4(),
            user_id=user_id,
            type=type_,
            title=title,
            message=message,
            is_read=False,
            related_entity_id=related_entity_id,
            deep_link=deep_link
        )
        db.add(notification)
        db.commit()
        db.refresh(notification)

        # 2. Check User Preferences
        prefs = db.query(NotificationPreference).filter(NotificationPreference.user_id == user_id).first()
        if not prefs:
            prefs = NotificationPreference(user_id=user_id)
            db.add(prefs)
            db.commit()

        # Determine if notification type is allowed
        allow_email = prefs.email_enabled
        allow_push = prefs.push_enabled

        if type_ == "MATCH" and not prefs.match_alerts:
            allow_email = allow_push = False
        elif type_ == "MESSAGE" and not prefs.message_alerts:
            allow_email = allow_push = False
        elif type_ == "VERIFICATION" and not prefs.verification_alerts:
            allow_email = allow_push = False

        # 3. Dispatch Email Notification (SMTP)
        if allow_email and user.email:
            user_name = user.profile.full_name if user.profile else "CoHabio User"
            EmailService._send_email(
                to_email=user.email,
                subject=f"CoHabio: {title}",
                html_content=f"""
                <div style="font-family: sans-serif; padding: 24px; background: #f8fafc; border-radius: 12px;">
                  <h2 style="color: #16A34A;">CoHabio Alert</h2>
                  <h3>{title}</h3>
                  <p style="font-size: 15px; color: #475569;">Hi <strong>{user_name}</strong>,</p>
                  <p style="font-size: 15px; color: #334155;">{message}</p>
                </div>
                """
            )

        # 4. Dispatch Mobile Push Notification (FCM / Mobile Token Service)
        if allow_push:
            tokens = db.query(DeviceToken).filter(
                DeviceToken.user_id == user_id,
                DeviceToken.is_active == True
            ).all()

            for token_rec in tokens:
                NotificationService._send_fcm_push(
                    token=token_rec.token,
                    title=title,
                    body=message,
                    data={"type": type_, "deep_link": deep_link or "", "related_id": related_entity_id or ""}
                )

        return notification

    @staticmethod
    def _send_fcm_push(token: str, title: str, body: str, data: Dict[str, str]) -> bool:
        """
        Sends push notification to mobile device using FCM / Simulated Push Engine.
        """
        logger.info(f"📱 [MOBILE PUSH NOTIFICATION] Token: {token[:12]}... | Title: {title} | Body: {body}")
        print(f"\n📲 [PUSH SIMULATOR] Device Token: {token[:16]}... | Payload: {title} -> {body} | DeepLink: {data.get('deep_link')}\n")
        return True

    @staticmethod
    def notify_roommate_match(db: Session, user1_id: uuid.UUID, user2_id: uuid.UUID, match_score: int):
        user2 = db.query(User).filter(User.id == user2_id).first()
        user2_name = user2.profile.full_name if user2 and user2.profile else "a compatible user"
        
        title = f"🎉 New {match_score}% Roommate Match!"
        message = f"You and {user2_name} matched with a {match_score}% compatibility score! Start a chat now to discuss flatshares."
        
        NotificationService.dispatch_notification(
            db=db,
            user_id=user1_id,
            type_="MATCH",
            title=title,
            message=message,
            related_entity_id=str(user2_id),
            deep_link="/matches"
        )

    @staticmethod
    def notify_new_message(db: Session, recipient_id: uuid.UUID, sender_name: str, message_preview: str, room_id: str):
        title = f"💬 New Message from {sender_name}"
        message = f"{message_preview[:60]}..." if len(message_preview) > 60 else message_preview
        
        NotificationService.dispatch_notification(
            db=db,
            user_id=recipient_id,
            type_="MESSAGE",
            title=title,
            message=message,
            related_entity_id=room_id,
            deep_link=f"/chat/{room_id}"
        )

    @staticmethod
    def notify_verification_update(db: Session, user_id: uuid.UUID, status_text: str):
        title = "🛡️ Verification Status Update"
        message = f"Your CoHabio verification status has been updated to: {status_text.replace('_', ' ').title()}."
        
        NotificationService.dispatch_notification(
            db=db,
            user_id=user_id,
            type_="VERIFICATION",
            title=title,
            message=message,
            deep_link="/profile"
        )
