# PostgreSQL Database Setup Guide

This guide walks you through setting up PostgreSQL database locally for Cohabio.

## Prerequisites
- PostgreSQL 15+ installed.
- Default `postgres` superuser password set.

## Steps

### 1. Automatic Database Creation
The FastAPI backend will automatically attempt to create the `cohabio` database on startup if it doesn't exist, using the parameters defined in `.env`.

### 2. Manual SQL Setup
If you wish to reset or configure the database manually:
1. Run the `setup.sql` script under database directory:
   ```bash
   psql -U postgres -f database/setup.sql
   ```
2. Set up the schema tables manually (optional, since ORM models do it on startup):
   ```bash
   psql -U postgres -d cohabio -f backend/schema.sql
   ```

### 3. Verification
Run the database check script or start the FastAPI backend:
```bash
cd backend
python -c "from app.db.session import engine; print('Database connected successfully!')"
```
