from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_waitlist_submission():
    response = client.post("/api/v1/waitlist", json={
        "email": "test_waitlist_user@cohabio.com",
        "full_name": "Test Waitlist User",
        "target_city": "Bangalore"
    })
    assert response.status_code in [200, 201, 400] # 400 if already exists

def test_public_bot_chat():
    response = client.post("/api/v1/public/bot/chat", json={
        "message": "Hello Cohabio AI, how does roommate matching work?",
        "history": []
    })
    assert response.status_code == 200
    data = response.json()
    assert "reply" in data
    assert len(data["reply"]) > 0

def test_housing_public_listing():
    response = client.get("/api/v1/housing/")
    # Returns 401 when unauthorized, or 200 if public
    assert response.status_code in [200, 401]

def test_communities_public_listing():
    response = client.get("/api/v1/communities/")
    assert response.status_code in [200, 401]
