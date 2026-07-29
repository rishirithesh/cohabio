from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_status():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "Cohabio" in data["project"]

def test_signup_validation_failure():
    # Email invalid or missing password
    response = client.post("/api/v1/auth/signup", json={
        "email": "not-an-email",
        "password": "short"
    })
    assert response.status_code in [400, 422]

def test_login_invalid_credentials():
    response = client.post("/api/v1/auth/login", json={
        "email": "nonexistent_user_999@cohabio.com",
        "password": "wrongpassword"
    })
    assert response.status_code in [400, 401, 404]

def test_simulated_google_auth():
    response = client.post("/api/v1/auth/google", json={
        "token": "simulated_test_token"
    })
    assert response.status_code in [200, 400, 401]
