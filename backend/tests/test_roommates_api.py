from fastapi.testclient import TestClient
from app.main import app
from app.services.roommate_algorithm import RoommateMatcher

client = TestClient(app)

def test_roommate_matcher_compatibility():
    profile_a = {
        "budget_min": 10000,
        "budget_max": 20000,
        "cleanliness_rating": 4,
        "sleep_schedule": "early",
        "work_schedule": "flexible",
        "smoking": False,
        "drinking": "socially",
        "pets": "no",
        "food_pref": "vegetarian",
        "interests": ["Tech", "Fitness"]
    }
    
    profile_b = {
        "budget_min": 12000,
        "budget_max": 22000,
        "cleanliness_rating": 4,
        "sleep_schedule": "early",
        "work_schedule": "flexible",
        "smoking": False,
        "drinking": "socially",
        "pets": "no",
        "food_pref": "vegetarian",
        "interests": ["Tech", "Reading"]
    }

    score = RoommateMatcher.calculate_compatibility(profile_a, profile_b)
    assert score >= 80  # High compatibility

    breakdown = RoommateMatcher.get_compatibility_breakdown(profile_a, profile_b)
    assert "match_score" in breakdown
    assert "matching_tags" in breakdown
    assert len(breakdown["matching_tags"]) > 0
