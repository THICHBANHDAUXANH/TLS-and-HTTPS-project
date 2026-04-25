-- =====================================================
-- File: 03_indexes.sql
-- Project: Personal Finance Management System
-- Purpose: Create indexes to improve query performance
-- =====================================================

USE personal_finance_db;

-- =====================================================
-- 1. Users Indexes
-- =====================================================
-- Email is frequently used for login.
-- Note: Email already has a UNIQUE constraint, which automatically creates an index.
-- Therefore, we do not create another index for Email here.

-- =====================================================
-- 2. Accounts Indexes
-- =====================================================
-- Used to quickly find all accounts owned by a user.
CREATE INDEX idx_accounts_user
ON Accounts(UserID);

-- Used to filter accounts by account type such as BANK, CASH, or EWALLET.
CREATE INDEX idx_accounts_type
ON Accounts(AccountType);

-- =====================================================
-- 3. Income Indexes
-- =====================================================
-- Used for monthly and yearly income reports.
CREATE INDEX idx_income_user_date
ON Income(UserID, IncomeDate);

-- Used to find income records linked to a specific account.
CREATE INDEX idx_income_account
ON Income(AccountID);

-- =====================================================
-- 4. Expenses Indexes
-- =====================================================
-- Used for monthly and yearly expense reports.
CREATE INDEX idx_expenses_user_date
ON Expenses(UserID, ExpenseDate);

-- Used for category-wise spending reports.
CREATE INDEX idx_expenses_category
ON Expenses(CategoryID);

-- Used to find expenses paid from a specific account.
CREATE INDEX idx_expenses_account
ON Expenses(AccountID);

-- Used for reports filtered by user, category, and date.
CREATE INDEX idx_expenses_user_category_date
ON Expenses(UserID, CategoryID, ExpenseDate);

-- =====================================================
-- 5. Budgets Indexes
-- =====================================================
-- Used to quickly find a budget by user, category, month, and year.
CREATE INDEX idx_budgets_user_category_month_year
ON Budgets(UserID, CategoryID, Month, Year);

-- =====================================================
-- 6. BalanceHistory Indexes
-- =====================================================
-- Used to quickly view balance history of a specific account.
CREATE INDEX idx_balance_history_account_date
ON BalanceHistory(AccountID, ChangeDate);

-- =====================================================
-- 7. Check Created Indexes
-- =====================================================
SHOW INDEX FROM Accounts;
SHOW INDEX FROM Income;
SHOW INDEX FROM Expenses;
SHOW INDEX FROM Budgets;
SHOW INDEX FROM BalanceHistory;