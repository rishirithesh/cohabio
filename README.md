# Cohabio — Find Your People. Find Your Place.

Cohabio is a community-first relocation & housing platform designed to assist students and young professionals moving to new cities. By establishing verified local communities, AI roommate compatibility algorithms, and relocation planning before the housing marketplace, Cohabio simplifies the journey of shifting to a new city.

---

## 🏗️ Architecture & Blueprint

Cohabio adopts **Clean Architecture** patterns separated into:
- **`mobile/`**: Flutter Mobile Application utilizing Riverpod for state management, GoRouter, and a tailored minimalist design system.
- **`backend/`**: FastAPI high-performance Python backend managing WebSockets chat, compatibility calculations, and Gemini AI endpoints.
- **`landing/`**: Premium, high-conversion landing waitlist website built with clean HTML/CSS design.

---

## 🚦 Getting Started

### Prerequisites
- Docker & Docker Compose
- Flutter SDK (v3.0.0+)
- Python 3.11+

### Backend & Database Setup
1. Copy the environment variables template:
   ```bash
   cp .env.example .env
   ```
2. Build and run the infrastructure using Docker:
   ```bash
   docker-compose up --build -d
   ```
3. The API documentation will be available at [http://localhost:8000/docs](http://localhost:8000/docs).

### Running the Mobile Client
1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Launch on emulator/device:
   ```bash
   flutter run
   ```

---

## ⚙️ AI Matching Compatibility
Roommates are matched dynamically using a 6-factor compatibility index:
- **Budget Overlap** (25%)
- **Cleanliness Ratings** (20%)
- **Lifestyle & Sleep Schedules** (20%)
- **Drinking & Smoking Habits** (15%)
- **Dietary & Food Choices** (10%)
- **Shared Interests & Affinity** (10%)
