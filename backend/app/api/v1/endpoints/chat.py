from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, select
from app.db.session import get_db
from app.models.models import User, ChatRoom, Message, chat_participants, Profile
from app.schemas.schemas import MessageResponse, ChatRoomResponse
from app.api.deps import get_current_user
from typing import List, Dict, Optional
import uuid
import json

router = APIRouter()

# Connection manager to broadcast and send direct messages in real time
class ConnectionManager:
    def __init__(self):
        # Maps active user IDs to their WebSocket connections
        self.active_connections: Dict[uuid.UUID, WebSocket] = {}

    async def connect(self, user_id: uuid.UUID, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: uuid.UUID):
        if user_id in self.active_connections:
            del self.active_connections[user_id]

    async def send_personal_message(self, message: str, user_id: uuid.UUID):
        if user_id in self.active_connections:
            await self.active_connections[user_id].send_text(message)

    async def broadcast_to_room(self, db: Session, room_id: uuid.UUID, sender_id: uuid.UUID, message_payload: dict):
        # Find all participants in the room
        participants = db.query(chat_participants).filter(chat_participants.c.room_id == room_id).all()
        for participant in participants:
            p_user_id = participant.user_id
            # Broadcast to all other active participants
            if p_user_id in self.active_connections:
                await self.active_connections[p_user_id].send_json(message_payload)

manager = ConnectionManager()

@router.get("/rooms", response_model=List[ChatRoomResponse])
def get_rooms(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Find all rooms the user participates in
    rooms_stmt = select(chat_participants.c.room_id).where(chat_participants.c.user_id == current_user.id)
    room_ids = db.execute(rooms_stmt).scalars().all()
    
    rooms = db.query(ChatRoom).filter(ChatRoom.id.in_(room_ids)).all()
    
    responses = []
    for room in rooms:
        # Find other participant details
        other_participant_stmt = select(chat_participants.c.user_id).where(
            and_(chat_participants.c.room_id == room.id, chat_participants.c.user_id != current_user.id)
        )
        other_user_id = db.execute(other_participant_stmt).scalar()
        
        recipient_name = "System Chat"
        recipient_avatar = None
        if other_user_id:
            profile = db.query(Profile).filter(Profile.user_id == other_user_id).first()
            if profile:
                recipient_name = profile.full_name
                recipient_avatar = profile.avatar_url
        
        # Get last message
        last_msg = db.query(Message).filter(Message.room_id == room.id).order_by(Message.created_at.desc()).first()
        
        responses.append(ChatRoomResponse(
            id=room.id,
            type=room.type,
            created_at=room.created_at,
            recipient_name=recipient_name,
            recipient_avatar=recipient_avatar,
            last_message=last_msg.content if last_msg else None,
            last_message_time=last_msg.created_at if last_msg else None
        ))
        
    return responses

@router.get("/rooms/{room_id}/messages", response_model=List[MessageResponse])
def get_room_messages(room_id: uuid.UUID, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Verify membership
    membership_stmt = select(chat_participants).where(
        and_(chat_participants.c.room_id == room_id, chat_participants.c.user_id == current_user.id)
    )
    is_member = db.execute(membership_stmt).first()
    if not is_member:
        raise HTTPException(status_code=403, detail="Not authorized to view messages in this chat room")
        
    messages = db.query(Message).filter(Message.room_id == room_id).order_by(Message.created_at.asc()).all()
    return messages

@router.websocket("/ws/{room_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: uuid.UUID, token: str, db: Session = Depends(get_db)):
    # Validate token manually since websockets don't support standard headers easily
    from app.core.security import decode_token
    payload = decode_token(token)
    if not payload:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return
        
    user_id = uuid.UUID(payload.get("sub"))
    
    # Verify membership
    membership_stmt = select(chat_participants).where(
        and_(chat_participants.c.room_id == room_id, chat_participants.c.user_id == user_id)
    )
    is_member = db.execute(membership_stmt).first()
    if not is_member:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    await manager.connect(user_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            payload = json.loads(data)
            
            # Types: message, typing, read_receipt
            event_type = payload.get("type", "message")
            
            if event_type == "message":
                content = payload.get("content", "")
                media_url = payload.get("media_url")
                
                # Save to database
                db_message = Message(
                    room_id=room_id,
                    sender_id=user_id,
                    content=content,
                    media_url=media_url,
                    is_read=False
                )
                db.add(db_message)
                db.commit()
                db.refresh(db_message)
                
                broadcast_data = {
                    "type": "message",
                    "id": str(db_message.id),
                    "room_id": str(room_id),
                    "sender_id": str(user_id),
                    "content": content,
                    "media_url": media_url,
                    "is_read": False,
                    "created_at": db_message.created_at.isoformat()
                }
                await manager.broadcast_to_room(db, room_id, user_id, broadcast_data)

                # Dispatch notification to recipient participants
                try:
                    from app.services.notification_service import NotificationService
                    participants = db.query(chat_participants).filter(
                        and_(chat_participants.c.room_id == room_id, chat_participants.c.user_id != user_id)
                    ).all()
                    sender_prof = db.query(Profile).filter(Profile.user_id == user_id).first()
                    sender_name = sender_prof.full_name if sender_prof else "User"
                    for p in participants:
                        NotificationService.notify_new_message(db, p.user_id, sender_name, content, str(room_id))
                except Exception as err:
                    print(f"Failed to dispatch message notification: {err}")
                
            elif event_type == "typing":
                broadcast_data = {
                    "type": "typing",
                    "sender_id": str(user_id),
                    "is_typing": payload.get("is_typing", False)
                }
                await manager.broadcast_to_room(db, room_id, user_id, broadcast_data)
                
            elif event_type == "read_receipt":
                # Mark messages as read in DB
                db.query(Message).filter(
                    and_(Message.room_id == room_id, Message.sender_id != user_id, Message.is_read == False)
                ).update({Message.is_read: True})
                db.commit()
                
                broadcast_data = {
                    "type": "read_receipt",
                    "room_id": str(room_id),
                    "reader_id": str(user_id)
                }
                await manager.broadcast_to_room(db, room_id, user_id, broadcast_data)

    except WebSocketDisconnect:
        manager.disconnect(user_id)
        # Notify typing stop
        broadcast_data = {
            "type": "typing",
            "sender_id": str(user_id),
            "is_typing": False
        }
        await manager.broadcast_to_room(db, room_id, user_id, broadcast_data)
