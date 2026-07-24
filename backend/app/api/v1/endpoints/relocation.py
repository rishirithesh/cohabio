from fastapi import APIRouter, Depends, HTTPException, Header
from app.schemas.schemas import RelocationQuery
from app.services.ai_gemini import GeminiRelocationAssistant
from typing import List, Dict, Any, Optional

router = APIRouter()
ai_assistant = GeminiRelocationAssistant()

@router.get("/checklists")
def get_checklists():
    return {
        "packing": [
            {"id": "p1", "task": "Pack electronics & chargers", "category": "Essentials", "completed": False},
            {"id": "p2", "task": "Organize academic/work documents", "category": "Documents", "completed": False},
            {"id": "p3", "task": "Sort clothes by climate", "category": "Apparel", "completed": False},
            {"id": "p4", "task": "Purchase basic toiletries kit", "category": "Hygiene", "completed": False}
        ],
        "utilities": [
            {"id": "u1", "task": "Cancel utility contracts at old place", "category": "Bills", "completed": False},
            {"id": "u2", "task": "Book a moving agency", "category": "Logistics", "completed": False},
            {"id": "u3", "task": "Confirm broadband installation date", "category": "Internet", "completed": False},
            {"id": "u4", "task": "Locate nearest local supermarket", "category": "Locals", "completed": False}
        ]
    }

@router.post("/assistant")
def relocation_advisor(query: RelocationQuery):
    advice = ai_assistant.get_relocation_advice(
        current_city=query.current_city,
        target_city=query.target_city,
        budget=query.budget,
        preferences=query.preferences
    )
    return {"advice": advice}

@router.get("/search/parse")
def parse_natural_search(query: str):
    parsed = ai_assistant.parse_natural_language_search(query)
    return parsed

