# Cohabio — Find Your People. Find Your Place.

> **AI-Powered Relocation, Roommate Matching & Verified Student Communities Platform**

**Founder**: Rishi Rithesh  
**Co-Founder**: Sathiya Priyan R, Justin Benito
**Funded By**: tonesofmadras, snuchennai, angel.investors
**License**: MIT  
**Platform**: iOS, Android & Web  

---

## 🌟 Overview

**Cohabio** is a modern, community-first relocation & housing platform designed specifically for students and young professionals moving to new cities. 

Instead of jumping straight to fragmented apartment listings, Cohabio simplifies urban migration through a three-step journey:
1. **Verified City & College Communities**: Connect with peers, alumni, and local groups before you arrive.
2. **AI Roommate Compatibility Matching**: Swipe and match with verified flatmates based on lifestyle preferences, budget, work schedule, and cleanliness ratings.
3. **Gemini AI Relocation Assistant**: Receive real-time neighborhood recommendations, cost-of-living estimates, transit guidance, and dynamic moving checklists powered by Google Gemini 1.5 Flash.

---

## ✨ Key Features & Product Highlights

- 📱 **Animated Mobile Startup & Micro-Interactions**: Custom spring logo scaling, smooth route page transitions using `go_router`, swipe card gestures, and custom dark mode Material 3 design system.
- 🔐 **Dual-Tier Trust & Verification**:
  - **Level 1 Email Verification**: Secure 6-digit OTP dispatched via SMTP with 10-minute expiration timers and 30-second resend rate limits.
  - **Level 2 Identity Verification**: Student ID, Employee Code, or Government ID verification unlocking official trust badges and higher recommendation placement.
- 🔑 **Google Sign-In & OAuth Integration**: One-tap sign-in with auto-provisioning of profiles and JWT access/refresh token issuing.
- 🤖 **Gemini 1.5 Flash Relocation Guide**: Natural language query parsing (e.g. *"Moving to Bangalore with 15k rent budget"*) returning tailored neighborhood analyses and moving timelines.
- 🏡 **Verified Housing Marketplace**: Explore PGs, single rooms, and shared apartments with distance metrics to major tech hubs and universities.
- 🛡️ **Role-Based Access Control (RBAC)**: Comprehensive backend authorization (`admin`, `moderator`, `user`, `owner`).

---

## 🛠️ Technology Stack

| Layer | Technologies Used |
| :--- | :--- |
| **Frontend Application** | Flutter 3.x, Riverpod 2.x, GoRouter 13.x, Dio, Flutter Secure Storage, Material 3, `flutter_animate`, Glassmorphism |
| **Backend API** | FastAPI (Python 3.13+), Pydantic v2, SQLAlchemy ORM, PyJWT, passlib bcrypt, `smtplib` |
| **Database** | PostgreSQL (Default `cohabio`, user `postgres`), SQLite local development fallback |
| **AI Relocation Assistant** | Google Gemini API (`gemini-1.5-flash`), `google-generativeai` SDK |
| **Authentication** | OAuth2 Bearer Tokens, Google OAuth 2.0, SMTP Email OTP Verification |

---

## 🚦 Quick Start Guide

### 1. Database Setup & Seeding
Ensure PostgreSQL (or local SQLite fallback) is ready, then run the root seed script:
```bash
python seed_data.py
```
*This automatically builds all database schema tables and seeds admin accounts, demo students, roommate swipe profiles, city communities, and housing listings.*

### 2. Launch FastAPI Backend Server
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- Interactive Swagger API Documentation: [http://localhost:8000/docs](http://localhost:8000/docs)
- Open API Schema: [http://localhost:8000/api/v1/openapi.json](http://localhost:8000/api/v1/openapi.json)

### 3. Launch Flutter Mobile Application
```bash
cd mobile
flutter pub get
flutter run
```

---

## 🔑 Seeded Demo & Admin Logins

Use these accounts to test specific roles and user flows:

| Account Type | Email Address | Password | Description / Role |
| :--- | :--- | :--- | :--- |
| **System Admin** | `mail.cohabio@gmail.com` | `Admin@123` | Official CoHabio Administrator |
| **Founder Admin** | `founder.cohabio@gmail.com` | `Founder@123` | Founder Admin Account |
| **Dev Test Student** | `student@gmail.com` | `Student@123` | **DEVELOPMENT / TEST ACCOUNT ONLY** (Pre-verified) |
| **Student User** | `student@cohabio.com` | `Student@123` | Seeded Student (Rohan Sharma) |
| **Moderator** | `moderator@cohabio.com` | `Moderator@123` | Content Moderator |
| **Property Owner** | `owner@cohabio.com` | `Owner@123` | Verified Property Owner |

---

## 📲 Android Studio & Physical Phone Testing

### Android Emulator (Studio)
- Open `/mobile` in **Android Studio**.
- Launch an emulator (Pixel 8, API 33/34).
- The emulator connects to the local backend automatically via `http://10.0.2.2:8000/api/v1`.

### Physical Android Phone (USB Debugging)
1. Enable **Developer Options** & **USB Debugging** on your phone.
2. Connect phone via USB and run:
   ```bash
   adb reverse tcp:8000 tcp:8000
   ```
3. Build & install the debug APK:
   ```bash
   cd mobile
   flutter build apk --debug
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

---

## 📁 Repository Structure

```text
Cohabio/
├── backend/                  # FastAPI Python backend server
│   ├── app/
│   │   ├── api/              # API endpoints (auth, relocation, roommates, etc.)
│   │   ├── core/             # App settings, security, JWT helpers
│   │   ├── db/               # Database session & engine
│   │   ├── models/           # SQLAlchemy models (User, Profile, Community, etc.)
│   │   ├── schemas/          # Pydantic validation schemas
│   │   └── services/         # Gemini AI, SMTP Email, Notification services
│   ├── requirements.txt      # Backend dependencies
│   └── seed_data.py          # Database seeder
├── mobile/                   # Flutter cross-platform mobile application
│   ├── lib/
│   │   ├── app/              # Theme & GoRouter configuration
│   │   ├── core/             # API client, network interceptors, state providers
│   │   └── features/         # Feature modules (auth, ai_assistant, roommate_matching, etc.)
│   └── pubspec.yaml          # Flutter package dependencies
├── landing/                  # Waitlist landing marketing page
├── docs/                     # API specs, Architecture, and Deployment guides
├── .env.example              # Environment variables template
├── seed_data.py              # Root launcher for database seeding
└── README.md                 # Project documentation
```

---

## 🤝 Contributing

Contributions are welcome! Please review [docs/CONTRIBUTING.md](file:///c:/5th%20Sem/Hackathon/Cohabio/docs/CONTRIBUTING.md) for details on our code style, commit standards, and pull request workflow.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](file:///c:/5th%20Sem/Hackathon/Cohabio/LICENSE) file for details.
