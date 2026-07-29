# Cohabio Comprehensive Local Setup Guide

Follow these step-by-step instructions to initialize and run the **Cohabio Ecosystem** (PostgreSQL Database, FastAPI Backend, Flutter Mobile App, and Landing Page) locally on your machine.

---

## 🛠️ Prerequisites

- **Python**: v3.11+
- **Flutter SDK**: v3.19.0+
- **PostgreSQL**: v15+ (Running locally on default port `5432` or via remote connection like Neon.tech)
- **Node.js** (Optional for Vercel CLI trial deployment)

---

## 💾 1. Environment & Database Configuration

1. Create a `.env` file in the root directory (or copy from `.env.example`):
   ```env
   POSTGRES_SERVER=localhost
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=your_password
   POSTGRES_DB=cohabio
   POSTGRES_PORT=5432
   SECRET_KEY=your_super_secret_jwt_key
   GEMINI_API_KEY=your_google_gemini_api_key
   ```

2. Seed initial tables, communities, properties, and demo roommate profiles:
   ```bash
   python seed_data.py
   ```

---

## ⚙️ 2. Run the FastAPI Backend Server

1. Navigate to the backend directory and install dependencies:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. Start the uvicorn development server:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

3. Open your browser and navigate to:
   - **Interactive API Documentation (Swagger)**: [http://localhost:8000/docs](http://localhost:8000/docs)
   - **Alternative ReDoc API Docs**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

---

## 📱 3. Launch the Flutter Mobile Application

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Start your Android Emulator or connect a physical device, then run:
   ```bash
   flutter run
   ```

4. **Features Available in Mobile App:**
   - **Communities**: Join city/college groups, post updates, like discussions.
   - **Matches**: Swipe on prospective roommates calculated via 6-factor algorithm.
   - **Housing**: Browse verified rental listings with room type filters and bookmarking.
   - **AI Guide**: Relocation chatbot, moving checklist, and budget calculator.
   - **Events**: Discover local flatmate get-togethers and RSVP.
   - **Chats**: Direct real-time messaging with WebSocket support.
   - **Alerts**: In-app notifications for matches and activities.
   - **Profile**: Edit demographic information and lifestyle preferences.

---

## 🌐 4. Open and Test the Landing Page

1. Open `landing/index.html` directly in your browser, or serve it using a simple HTTP server:
   ```bash
   cd landing
   python -m http.server 3000
   ```
2. Access [http://localhost:3000](http://localhost:3000).
3. Test early access waitlist form submission.
4. Interact with the live AI Chatbot floating widget in the bottom right corner.
