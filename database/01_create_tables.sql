-- =====================================================
-- File: 01_create_tables.sql
-- Project: Personal Finance Management System
-- Purpose: Create all database tables
-- =====================================================

USE personal_finance_db;

-- Drop tables if they already exist
DROP TABLE IF EXISTS BalanceHistory;
DROP TABLE IF EXISTS Budgets;
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Income;
DROP TABLE IF EXISTS ExpenseCategories;
DROP TABLE IF EXISTS Accounts;
DROP TABLE IF EXISTS Users;

-- =====================================================
-- 1. Users Table
-- =====================================================
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20),
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. Accounts Table
-- AccountType: BANK, CASH, EWALLET
-- =====================================================
CREATE TABLE Accounts (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    AccountName VARCHAR(100) NOT NULL,
    AccountType ENUM('BANK', 'CASH', 'EWALLET') NOT NULL,
    Balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_accounts_user
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE,

    CONSTRAINT chk_account_balance
        CHECK (Balance >= 0)
);

-- =====================================================
-- 3. ExpenseCategories Table
-- =====================================================
CREATE TABLE ExpenseCategories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

-- =====================================================
-- 4. Income Table
-- =====================================================
CREATE TABLE Income (
    IncomeID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    AccountID INT NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    IncomeDate DATE NOT NULL,
    Description VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_income_user
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE,

    CONSTRAINT fk_income_account
        FOREIGN KEY (AccountID)
        REFERENCES Accounts(AccountID)
        ON DELETE CASCADE,

    CONSTRAINT chk_income_amount
        CHECK (Amount > 0)
);

-- =====================================================
-- 5. Expenses Table
-- =====================================================
CREATE TABLE Expenses (
    ExpenseID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    AccountID INT NOT NULL,
    CategoryID INT NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    ExpenseDate DATE NOT NULL,
    Description VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_expense_user
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE,

    CONSTRAINT fk_expense_account
        FOREIGN KEY (AccountID)
        REFERENCES Accounts(AccountID)
        ON DELETE CASCADE,

    CONSTRAINT fk_expense_category
        FOREIGN KEY (CategoryID)
        REFERENCES ExpenseCategories(CategoryID)
        ON DELETE RESTRICT,

    CONSTRAINT chk_expense_amount
        CHECK (Amount > 0)
);

-- =====================================================
-- 6. Budgets Table
-- =====================================================
CREATE TABLE Budgets (
    BudgetID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    Month INT NOT NULL,
    Year INT NOT NULL,
    LimitAmount DECIMAL(15,2) NOT NULL,

    CONSTRAINT fk_budget_user
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID)
        ON DELETE CASCADE,

    CONSTRAINT fk_budget_category
        FOREIGN KEY (CategoryID)
        REFERENCES ExpenseCategories(CategoryID)
        ON DELETE CASCADE,

    CONSTRAINT chk_budget_month
        CHECK (Month BETWEEN 1 AND 12),

    CONSTRAINT chk_budget_year
        CHECK (Year >= 2000),

    CONSTRAINT chk_budget_limit
        CHECK (LimitAmount > 0),

    CONSTRAINT uq_user_category_month_year
        UNIQUE (UserID, CategoryID, Month, Year)
);

-- =====================================================
-- 7. BalanceHistory Table
-- =====================================================
CREATE TABLE BalanceHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT NOT NULL,
    ChangeAmount DECIMAL(15,2) NOT NULL,
    BalanceAfter DECIMAL(15,2) NOT NULL,
    ChangeType ENUM('INCOME', 'EXPENSE') NOT NULL,
    ChangeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReferenceID INT,

    CONSTRAINT fk_balance_account
        FOREIGN KEY (AccountID)
        REFERENCES Accounts(AccountID)
        ON DELETE CASCADE
);

-- Check created tables
SHOW TABLES;