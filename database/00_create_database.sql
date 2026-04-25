-- =====================================================
-- File: 00_create_database.sql
-- Project: Personal Finance Management System
-- Purpose: Create the database for the project
-- =====================================================

-- Drop the database if it already exists.
-- This makes the setup reproducible from the beginning.
DROP DATABASE IF EXISTS personal_finance_db;

-- Create a new database.
CREATE DATABASE personal_finance_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Select the database for later SQL scripts.
USE personal_finance_db;

-- Check current selected database.
SELECT DATABASE() AS CurrentDatabase;