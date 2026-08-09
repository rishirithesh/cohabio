from fastapi import APIRouter, HTTPException, Request, status
from pydantic import BaseModel, Field
from typing import List, Dict
from datetime import datetime, timedelta
from app.services.ai_gemini import GeminiRelocationAssistant

router = APIRouter()

class ChatMessage(BaseModel):
    message: str = Field(..., min_length=1, max_length=150)
    history: List[Dict[str, str]] = Field(default_factory=list, max_length=10)

# Simple in-memory rate limiter for public unauthenticated endpoints
# Dictionary structure: { "ip_address": {"count": int, "reset_time": datetime} }
RATE_LIMIT_STORE: Dict[str, Dict[str, any]] = {}
MAX_REQUESTS_PER_MINUTE = 10

def check_rate_limit(client_ip: str):
    now = datetime.utcnow()
    
    if client_ip not in RATE_LIMIT_STORE:
        RATE_LIMIT_STORE[client_ip] = {"count": 1, "reset_time": now + timedelta(minutes=1)}
        return
        
    record = RATE_LIMIT_STORE[client_ip]
    
    if now > record["reset_time"]:
        # Reset counter
        record["count"] = 1
        record["reset_time"] = now + timedelta(minutes=1)
        return
        
    if record["count"] >= MAX_REQUESTS_PER_MINUTE:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="You're sending messages too fast! Please wait a moment."
        )
        
    record["count"] += 1

@router.post("/chat")
def public_bot_chat(data: ChatMessage, request: Request):
    client_ip = request.client.host if request.client else "unknown"
    check_rate_limit(client_ip)
    
    if not data.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty.")
        
    assistant = GeminiRelocationAssistant()
    response_text = assistant.get_landing_page_chat_response(
        message=data.message.strip(),
        chat_history=data.history
    )
    
    return {"reply": response_text}
