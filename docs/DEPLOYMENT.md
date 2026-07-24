# Cohabio Deployment & Google Sign-In Guide

This document provides exact instructions to deploy Cohabio (Website & Backend) and configure true Google Sign-In using OAuth 2.0.

---

## 1. Google Sign-In Setup (Google Cloud Console)

To enable Google Sign-In for both the Landing Page (Web) and Mobile Application (Android), follow these exact steps:

### A. Create Project & Consent Screen
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project named **Cohabio**.
3. Navigate to **APIs & Services > OAuth consent screen**.
4. Choose **External** (unless you have a Google Workspace for testing).
5. Fill in App Name ("Cohabio"), User Support Email, and Developer Contact Information.
6. Add Scopes: `.../auth/userinfo.email` and `.../auth/userinfo.profile`.
7. Add Test Users (e.g., your own gmail address) if the app is in testing mode.

### B. Create Web OAuth Credentials (For Landing Page & Backend)
1. Navigate to **Credentials > Create Credentials > OAuth client ID**.
2. Application type: **Web application**.
3. Name: **Cohabio Web Client**.
4. Authorized JavaScript origins:
   - `http://localhost:8000` (for local development)
   - `https://your-vercel-domain.vercel.app` (for production)
5. Authorized redirect URIs: Not strictly needed for Google Identity Services popup mode, but good to add the above domains.
6. Click **Create**.
7. **IMPORTANT:** Save the **Web Client ID**. You do *not* need the Client Secret for ID token validation in FastAPI.

### C. Create Android OAuth Credentials (For Flutter App)
1. Navigate to **Credentials > Create Credentials > OAuth client ID**.
2. Application type: **Android**.
3. Name: **Cohabio Android Client**.
4. Package name: `com.cohabio.app` (verify this in your `android/app/build.gradle`).
5. **SHA-1 Fingerprint:**
   - Run this command in your Flutter project root to get your debug key:
     ```bash
     cd android
     ./gradlew signingReport
     ```
   - Copy the SHA-1 value from the `debug` variant.
6. Click **Create**.

### D. Update Application Configurations
1. **Landing Page (`landing/index.html`)**:
   - Replace `YOUR_GOOGLE_WEB_CLIENT_ID` with the **Web Client ID** you generated in Step B.
2. **Backend (`.env`)**:
   - Add `GOOGLE_CLIENT_ID=your-web-client-id-from-step-b`. (FastAPI needs this to validate the token).
3. **Flutter App (`auth_landing_screen.dart`)**:
   - In production, pass the **Web Client ID** to the `serverClientId` property in the `GoogleSignIn` constructor to receive the `idToken` successfully on Android.

---

## 2. Zero-Cost Deployment Architecture

The recommended architecture for deploying Cohabio quickly without spending money:

### A. Landing Page Deployment (Vercel)
Vercel is perfect for hosting static sites (HTML/CSS/JS) with automatic SSL and CDN.

1. Install the Vercel CLI: `npm i -g vercel`
2. Navigate to the landing directory:
   ```bash
   cd landing
   ```
3. Deploy to production:
   ```bash
   vercel --prod
   ```
4. Follow the prompts. Vercel will provide a public URL (e.g., `https://cohabio-landing.vercel.app`).
5. *Update the Waitlist form (`script.js`) to point to your new Render backend URL instead of `localhost:8000`.*

### B. Database Deployment (Neon.tech)
Neon provides a free serverless PostgreSQL database.

1. Create a free account at [Neon.tech](https://neon.tech).
2. Create a new project and database named `cohabio`.
3. Copy the Connection String (starts with `postgresql://`).

### C. Backend Deployment (Render.com)
Render offers a free tier for Python web services.

1. Push your backend code to GitHub.
2. Create a free account at [Render.com](https://render.com).
3. Click **New > Web Service** and connect your GitHub repository.
4. Settings:
   - Root Directory: `backend`
   - Environment: `Python 3`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Environment Variables:
   - Add `DATABASE_URL` (paste the Neon connection string).
   - Add `GEMINI_API_KEY`
   - Add `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`
   - Add `GOOGLE_CLIENT_ID` (from step 1B)
6. Deploy! Render will give you a public URL (e.g., `https://cohabio-backend.onrender.com`).

---

## 3. Mobile Application Checklist

Before releasing the Android APK to the Google Play Console:

- [ ] **Google Sign-In:** Ensure the Web Client ID is passed as `serverClientId` in `auth_landing_screen.dart`.
- [ ] **Release SHA-1:** When building a release app bundle (`flutter build appbundle`), you must generate a production Keystore, get its SHA-1, and add it to the Google Cloud Console (Create a new Android OAuth client with the release SHA-1).
- [ ] **Backend URL:** Update `apiClient.dart` (or `api_constants.dart`) to point to the production Render URL instead of `10.0.2.2`.
- [ ] **Build Command:** `flutter build apk --release` (or `appbundle`).
