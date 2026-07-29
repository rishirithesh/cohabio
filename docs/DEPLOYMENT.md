# Cohabio Production Deployment & Google Sign-In Guide

This document provides complete instructions to deploy the entire Cohabio platform (Landing Page Web, FastAPI Backend, Neon PostgreSQL Database) and package the Flutter Mobile Application for trial and production release.

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
   - `https://cohabio-landing.vercel.app` (for production)
5. Authorized redirect URIs: Add your production domains.
6. Click **Create**.
7. **IMPORTANT:** Save the **Web Client ID**. You do *not* need the Client Secret for ID token validation in FastAPI.

### C. Create Android OAuth Credentials (For Flutter App)
1. Navigate to **Credentials > Create Credentials > OAuth client ID**.
2. Application type: **Android**.
3. Name: **Cohabio Android Client**.
4. Package name: `com.cohabio.app` (verify in `android/app/build.gradle`).
5. **SHA-1 Fingerprint:**
   - Run this command in your Flutter project root to get your debug key:
     ```bash
     cd android
     ./gradlew signingReport
     ```
   - Copy the SHA-1 value from the `debug` variant.
6. Click **Create**.

---

## 2. Zero-Cost Production Deployment Architecture

The recommended architecture for deploying Cohabio quickly without spending money:

### A. Landing Page Trial Deployment (Vercel)
Vercel hosts static sites (HTML/CSS/JS) with zero configuration, SSL, and global CDN.

1. **Option 1: Vercel CLI Deployment**
   ```bash
   npm i -g vercel
   cd landing
   vercel --prod
   ```
2. **Option 2: GitHub Integration**
   - Connect your GitHub repository to Vercel.
   - Set Root Directory to `landing`.
   - Vercel will auto-deploy on every commit to `main`/`dev`.
3. Set the global backend variable in `landing/index.html` header if pointing to production backend:
   ```html
   <script>window.COHABIO_API_URL = "https://cohabio-backend.onrender.com";</script>
   ```

### B. Database Deployment (Neon.tech)
Neon provides a free serverless PostgreSQL database.

1. Create a free account at [Neon.tech](https://neon.tech).
2. Create a new project and database named `cohabio`.
3. Copy the Connection String (starts with `postgresql://...`).

### C. Backend Deployment (Render.com)
Render offers a free tier for Python web services with Docker or native Uvicorn support.

1. Push your code to GitHub.
2. Create a free account at [Render.com](https://render.com).
3. Click **New > Web Service** and select your repository.
4. Configurations:
   - **Root Directory:** `backend`
   - **Environment:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. **Environment Variables:**
   - `POSTGRES_SERVER` / `DATABASE_URL` (Neon Postgres URI)
   - `SECRET_KEY` (Strong random string)
   - `GEMINI_API_KEY` (Google AI Studio Key)
   - `GOOGLE_CLIENT_ID` (Web Client ID from Step 1B)
6. Click **Deploy**. Render will generate a public HTTPS endpoint (e.g. `https://cohabio-backend.onrender.com`).

---

## 3. Mobile Application Release & APK Packaging

Before distributing the Android APK for trial or releasing to the Google Play Store:

1. **Update Backend Base URL:**
   In `mobile/lib/core/network/api_client.dart`, set `baseUrl` to your deployed backend:
   ```dart
   static const String baseUrl = 'https://cohabio-backend.onrender.com/api/v1';
   ```

2. **Build Release APK (For Direct Trial / Testing):**
   ```bash
   cd mobile
   flutter build apk --release
   ```
   The generated APK will be located at:
   `mobile/build/app/outputs/flutter-apk/app-release.apk`

3. **Build App Bundle (For Google Play Store Release):**
   ```bash
   flutter build appbundle --release
   ```
   The output bundle file will be at:
   `mobile/build/app/outputs/bundle/release/app-release.aab`
