-- Cohabio Database Setup Script
-- Run this script using psql or PgAdmin to prepare the database.

-- Note: Run as superuser (e.g. postgres)
-- Close existing connections to database if exists
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'cohabio' AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS cohabio;

CREATE DATABASE cohabio;

-- Connect to the newly created database and run the schema setup if needed
\c cohabio

-- Enable UUID generation extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User and permission configuration
-- Check if user already exists
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'postgres') THEN
      CREATE ROLE postgres WITH SUPERUSER LOGIN PASSWORD 'postgres';
   END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE cohabio TO postgres;
