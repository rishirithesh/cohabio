# Cohabio Local Setup Guide

Follow these steps to run Cohabio locally on your machine.

## Prerequisites
- Python 3.11+
- Flutter SDK (v3.0.0+)
- PostgreSQL 15+ installed and running.

---

## 💾 1. Database Configuration
1. Initialize local tables and seed data using our root script:
   ```bash
   python seed_data.py
   ```
   This will verify connection parameters in `.env`, build tables, and seed the demo profiles.

---

## ⚙️ 2. Run the FastAPI Backend
1. Install Python requirements:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```
2. Start the FastAPI local server:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   Check [http://localhost:8000/docs](http://localhost:8000/docs) to verify Swagger works.

---

## 📱 3. Launch the Flutter Client
1. Navigate to the mobile folder:
   ```bash
   cd mobile
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on your target emulator/device:
   ```bash
   flutter run
   ```

---

## 🚀 4. Open the Landing Page
1. Open the file `landing/index.html` in your browser.
2. Submit a waitlist entry to confirm it propagates to the backend server.
