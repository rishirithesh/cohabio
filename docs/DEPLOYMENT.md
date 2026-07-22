# Cohabio Production Deployment Guide

This document details recommendations for launching Cohabio in a cloud production environment.

## ⚙️ Backend Services (FastAPI)
- **Containerization**: Use the provided `Dockerfile` to build your backend image.
- **Hosting Platforms**: Deploy containerized API tasks on AWS ECS, GCP Cloud Run, or Render.
- **Reverse Proxy**: Place Nginx or Caddy in front of uvicorn to handle TLS termination, limit rate payloads, and securely manage WebSocket connections.

## 💾 Managed Database (PostgreSQL)
- **Engine**: Deploy on AWS RDS PostgreSQL or Supabase Database.
- **Migrations**: Apply Alembic migrations on deployment pipelines before rolling out new containers.

## 📱 Mobile App (Flutter)
- **Android**: Build your release APK or AAB bundle:
  ```bash
  flutter build appbundle --release
  ```
- **iOS**: Compile your IPA via Xcode archives:
  ```bash
  flutter build ipa --release
  ```
