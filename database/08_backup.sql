-- =====================================================
-- File: 08_backup.sql
-- Project: Personal Finance Management System
-- Purpose: Backup and recovery instructions
-- =====================================================

USE personal_finance_db;

-- =====================================================
-- 1. Check current database
-- =====================================================
SELECT DATABASE() AS CurrentDatabase;

-- =====================================================
-- 2. Check all tables before backup
-- =====================================================
SHOW TABLES;

-- =====================================================
-- 3. Check number of records in each table
-- =====================================================
SELECT 'Users' AS TableName, COUNT(*) AS TotalRecords FROM Users
UNION ALL
SELECT 'Accounts', COUNT(*) FROM Accounts
UNION ALL
SELECT 'ExpenseCategories', COUNT(*) FROM ExpenseCategories
UNION ALL
SELECT 'Income', COUNT(*) FROM Income
UNION ALL
SELECT 'Expenses', COUNT(*) FROM Expenses
UNION ALL
SELECT 'Budgets', COUNT(*) FROM Budgets
UNION ALL
SELECT 'BalanceHistory', COUNT(*) FROM BalanceHistory;

-- =====================================================
-- 4. Backup command
-- =====================================================
-- The following command should be executed in Command Prompt or Terminal,
-- not inside MySQL Workbench SQL editor.
--
-- Windows example:
-- mysqldump -u root -p personal_finance_db > personal_finance_backup.sql
--
-- If mysqldump is not recognized, use the full path, for example:
-- "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqldump.exe" -u root -p personal_finance_db > personal_finance_backup.sql
--
-- macOS/Linux example:
-- mysqldump -u root -p personal_finance_db > personal_finance_backup.sql

-- =====================================================
-- 5. Restore command
-- =====================================================
-- The following command should also be executed in Command Prompt or Terminal.
--
-- mysql -u root -p personal_finance_db < personal_finance_backup.sql
--
-- If the database does not exist before restoring, create it first:
-- CREATE DATABASE personal_finance_db;