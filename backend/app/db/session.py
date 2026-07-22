import psycopg2
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

# Helper to automatically create database if missing
def init_db_connection():
    # Connect to default postgres DB first to check/create cohabio database
    try:
        conn = psycopg2.connect(
            dbname="postgres",
            user=settings.POSTGRES_USER,
            password=settings.POSTGRES_PASSWORD,
            host=settings.POSTGRES_SERVER,
            port=settings.POSTGRES_PORT
        )
        conn.autocommit = True
        cursor = conn.cursor()
        cursor.execute(f"SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{settings.POSTGRES_DB}'")
        exists = cursor.fetchone()
        if not exists:
            cursor.execute(f"CREATE DATABASE {settings.POSTGRES_DB}")
            print(f"Database {settings.POSTGRES_DB} created successfully.")
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Auto-database creation check skipped or failed: {e}")

init_db_connection()

engine = create_engine(
    settings.get_database_url(),
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
