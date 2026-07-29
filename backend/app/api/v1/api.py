from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth,
    profiles,
    communities,
    roommates,
    housing,
    chat,
    relocation,
    events,
    admin,
    waitlist,
    notifications,
    public_bot
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(profiles.router, prefix="/profiles", tags=["profiles"])
api_router.include_router(communities.router, prefix="/communities", tags=["communities"])
api_router.include_router(roommates.router, prefix="/roommates", tags=["roommates"])
api_router.include_router(housing.router, prefix="/housing", tags=["housing"])
api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
api_router.include_router(relocation.router, prefix="/relocation", tags=["relocation"])
api_router.include_router(events.router, prefix="/events", tags=["events"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
api_router.include_router(waitlist.router, prefix="/waitlist", tags=["waitlist"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
api_router.include_router(public_bot.router, prefix="/public/bot", tags=["public_bot"])
