# Cohabio Testing Suite & Quality Assurance Guide

This guide details how to execute unit, integration, and UI tests across both the **FastAPI Backend** and the **Flutter Mobile Application**.

---

## ⚙️ 1. Backend Testing (FastAPI & Pytest)

The backend test suite is located in `backend/tests` and uses `pytest` and FastAPI's `TestClient`.

### Prerequisites:
Ensure virtual environment is activated and dependencies are installed:
```bash
cd backend
pip install -r requirements.txt
```

### Run All Backend Tests:
```bash
pytest -v
```

### Run Specific Test Modules:
- **Authentication & OAuth API Tests:**
  ```bash
  pytest tests/test_auth_api.py -v
  ```
- **Roommate Matching Algorithm & Compatibility Score Tests:**
  ```bash
  pytest tests/test_roommates_api.py -v
  ```
- **Housing, Communities, Waitlist & AI Public Bot Tests:**
  ```bash
  pytest tests/test_features_api.py -v
  ```

---

## 📱 2. Flutter Client Testing (Mobile Application)

Flutter checks are split into unit tests (`auth_provider_test.dart`), widget layouts (`widget_test.dart`), and feature integration drivers in `mobile/test/`.

### Prerequisites:
Ensure Flutter SDK dependencies are fetched:
```bash
cd mobile
flutter pub get
```

### Run All Flutter Tests:
```bash
flutter test
```

### Run Specific Test Files:
```bash
flutter test test/auth_provider_test.dart
flutter test test/widget_test.dart
```

---

## 🌐 3. Landing Page & Web Verification

1. Open `landing/index.html` in your browser.
2. Submit a test entry to the waitlist form to verify backend response handling.
3. Click the floating AI Chatbot widget (bottom right) to verify natural language response handling from `/api/v1/public/bot/chat`.
