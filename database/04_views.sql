-- =====================================================
-- File: 04_views.sql
-- Project: Personal Finance Management System
-- Purpose: Create views for financial reports and analysis
-- =====================================================

USE personal_finance_db;

-- =====================================================
-- Drop existing views if they already exist
-- =====================================================
DROP VIEW IF EXISTS vw_transaction_history;
DROP VIEW IF EXISTS vw_account_balance_summary;
DROP VIEW IF EXISTS vw_budget_status;
DROP VIEW IF EXISTS vw_category_wise_spending;
DROP VIEW IF EXISTS vw_monthly_financial_summary;

-- =====================================================
-- 1. Monthly Financial Summary View
-- Shows total income, total expense, and savings by user/month/year
-- =====================================================
CREATE VIEW vw_monthly_financial_summary AS
SELECT
    u.UserID,
    u.UserName,
    ym.Year,
    ym.Month,
    COALESCE(i.TotalIncome, 0) AS TotalIncome,
    COALESCE(e.TotalExpense, 0) AS TotalExpense,
    COALESCE(i.TotalIncome, 0) - COALESCE(e.TotalExpense, 0) AS Savings
FROM Users u
JOIN (
    SELECT UserID, YEAR(IncomeDate) AS Year, MONTH(IncomeDate) AS Month
    FROM Income
    UNION
    SELECT UserID, YEAR(ExpenseDate) AS Year, MONTH(ExpenseDate) AS Month
    FROM Expenses
) ym ON u.UserID = ym.UserID
LEFT JOIN (
    SELECT 
        UserID,
        YEAR(IncomeDate) AS Year,
        MONTH(IncomeDate) AS Month,
        SUM(Amount) AS TotalIncome
    FROM Income
    GROUP BY UserID, YEAR(IncomeDate), MONTH(IncomeDate)
) i 
    ON ym.UserID = i.UserID
    AND ym.Year = i.Year
    AND ym.Month = i.Month
LEFT JOIN (
    SELECT 
        UserID,
        YEAR(ExpenseDate) AS Year,
        MONTH(ExpenseDate) AS Month,
        SUM(Amount) AS TotalExpense
    FROM Expenses
    GROUP BY UserID, YEAR(ExpenseDate), MONTH(ExpenseDate)
) e 
    ON ym.UserID = e.UserID
    AND ym.Year = e.Year
    AND ym.Month = e.Month;

-- =====================================================
-- 2. Category-wise Spending View
-- Shows total spending by user, month, year, and category
-- =====================================================
CREATE VIEW vw_category_wise_spending AS
SELECT
    e.UserID,
    u.UserName,
    YEAR(e.ExpenseDate) AS Year,
    MONTH(e.ExpenseDate) AS Month,
    c.CategoryID,
    c.CategoryName,
    COUNT(e.ExpenseID) AS NumberOfTransactions,
    SUM(e.Amount) AS TotalSpent
FROM Expenses e
JOIN Users u 
    ON e.UserID = u.UserID
JOIN ExpenseCategories c 
    ON e.CategoryID = c.CategoryID
GROUP BY 
    e.UserID,
    u.UserName,
    YEAR(e.ExpenseDate),
    MONTH(e.ExpenseDate),
    c.CategoryID,
    c.CategoryName;

-- =====================================================
-- 3. Budget Status View
-- Compares actual spending with planned budget
-- =====================================================
CREATE VIEW vw_budget_status AS
SELECT
    b.BudgetID,
    b.UserID,
    u.UserName,
    b.CategoryID,
    c.CategoryName,
    b.Year,
    b.Month,
    b.LimitAmount,
    COALESCE(SUM(e.Amount), 0) AS ActualSpent,
    b.LimitAmount - COALESCE(SUM(e.Amount), 0) AS RemainingAmount,
    CASE
        WHEN COALESCE(SUM(e.Amount), 0) > b.LimitAmount THEN 'OVER_BUDGET'
        WHEN COALESCE(SUM(e.Amount), 0) >= b.LimitAmount * 0.8 THEN 'WARNING'
        ELSE 'SAFE'
    END AS BudgetStatus
FROM Budgets b
JOIN Users u 
    ON b.UserID = u.UserID
JOIN ExpenseCategories c 
    ON b.CategoryID = c.CategoryID
LEFT JOIN Expenses e 
    ON b.UserID = e.UserID
    AND b.CategoryID = e.CategoryID
    AND b.Year = YEAR(e.ExpenseDate)
    AND b.Month = MONTH(e.ExpenseDate)
GROUP BY
    b.BudgetID,
    b.UserID,
    u.UserName,
    b.CategoryID,
    c.CategoryName,
    b.Year,
    b.Month,
    b.LimitAmount;

-- =====================================================
-- 4. Account Balance Summary View
-- Shows all accounts and their current balances
-- =====================================================
CREATE VIEW vw_account_balance_summary AS
SELECT
    a.AccountID,
    a.UserID,
    u.UserName,
    a.AccountName,
    a.AccountType,
    a.Balance,
    a.CreatedAt
FROM Accounts a
JOIN Users u
    ON a.UserID = u.UserID;

-- =====================================================
-- 5. Transaction History View
-- Combines income and expenses into one transaction list
-- =====================================================
CREATE VIEW vw_transaction_history AS
SELECT
    i.IncomeID AS TransactionID,
    i.UserID,
    u.UserName,
    i.AccountID,
    a.AccountName,
    a.AccountType,
    'INCOME' AS TransactionType,
    'Income' AS CategoryName,
    i.Amount AS Amount,
    i.Amount AS SignedAmount,
    i.IncomeDate AS TransactionDate,
    i.Description
FROM Income i
JOIN Users u 
    ON i.UserID = u.UserID
JOIN Accounts a 
    ON i.AccountID = a.AccountID

UNION ALL

SELECT
    e.ExpenseID AS TransactionID,
    e.UserID,
    u.UserName,
    e.AccountID,
    a.AccountName,
    a.AccountType,
    'EXPENSE' AS TransactionType,
    c.CategoryName AS CategoryName,
    e.Amount AS Amount,
    -e.Amount AS SignedAmount,
    e.ExpenseDate AS TransactionDate,
    e.Description
FROM Expenses e
JOIN Users u 
    ON e.UserID = u.UserID
JOIN Accounts a 
    ON e.AccountID = a.AccountID
JOIN ExpenseCategories c 
    ON e.CategoryID = c.CategoryID;

-- =====================================================
-- Check created views
-- =====================================================
SHOW FULL TABLES 
WHERE Table_type = 'VIEW';

-- =====================================================
-- Preview views
-- =====================================================
SELECT * FROM vw_monthly_financial_summary
ORDER BY UserID, Year, Month;

SELECT * FROM vw_category_wise_spending
ORDER BY UserID, Year, Month, TotalSpent DESC;

SELECT * FROM vw_budget_status
ORDER BY UserID, Year, Month, CategoryID;

SELECT * FROM vw_account_balance_summary
ORDER BY UserID, AccountID;

SELECT * FROM vw_transaction_history
ORDER BY UserID, TransactionDate, TransactionType;