# Cohabio — Find Your People. Find Your Place.
## Founder - Rishi Rithesh

Cohabio is a community-first relocation & housing platform designed to assist students and young professionals moving to new cities. By establishing verified local communities, AI roommate compatibility algorithms, and relocation planning before the housing marketplace, Cohabio simplifies the journey of shifting to a new city.

---

## 🏗️ Technical Stack

- **Frontend**: Flutter (latest stable), Riverpod, GoRouter, Flutter Hooks, Dio, Flutter Secure Storage, Material 3.
- **Backend**: FastAPI, Python 3.13+, SQLAlchemy, Pydantic v2, JWT Auth, WebSockets.
- **Database**: PostgreSQL (Default Name: `cohabio`, user: `postgres`, password: `rishi` / configured via `.env`).
- **AI Assistant**: Google Gemini API integration.

---

## 🚦 Getting Started

### 1. Database Setup & Seeding
Ensure PostgreSQL is running locally on port 5432, then run:
```bash
python seed_data.py
```
This automatically connects, builds tables, and inserts all MVP demo records.

### 2. Launch FastAPI Server
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Swagger documentation is interactive at: [http://localhost:8000/docs](http://localhost:8000/docs).

### 3. Launch Flutter Application
```bash
cd mobile
flutter pub get
flutter run
```

### 4. Waitlist Landing Page
Double click `landing/index.html` to open the marketing page. Waitlist submissions will save directly to your local database!

---

## 🔑 Seeded Demo Credentials

Use these logins to test specific user flows and permissions:

- **Admin Account**
  - **Email**: `admin@cohabio.com`
  - **Password**: `Admin@123`
- **Moderator Account**
  - **Email**: `moderator@cohabio.com`
  - **Password**: `Moderator@123`
- **Student Account**
  - **Email**: `student@cohabio.com`
  - **Password**: `Student@123`
- **Owner Account**
  - **Email**: `owner@cohabio.com`
  - **Password**: `Owner@123`
