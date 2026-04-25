-- =====================================================
-- File: 05_functions.sql
-- Project: Personal Finance Management System
-- Purpose: Create user-defined functions for financial calculations
-- =====================================================

USE personal_finance_db;

-- =====================================================
-- Drop existing functions if they already exist
-- =====================================================
DROP FUNCTION IF EXISTS fn_total_income;
DROP FUNCTION IF EXISTS fn_total_expense;
DROP FUNCTION IF EXISTS fn_net_savings;
DROP FUNCTION IF EXISTS fn_budget_status;

DELIMITER $$

-- =====================================================
-- 1. Function: fn_total_income
-- Returns total income of a user in a specific month and year
-- =====================================================
CREATE FUNCTION fn_total_income(
    p_UserID INT,
    p_Month INT,
    p_Year INT
)
RETURNS DECIMAL(15,2)
READS SQL DATA
BEGIN
    DECLARE v_TotalIncome DECIMAL(15,2);

    SELECT COALESCE(SUM(Amount), 0)
    INTO v_TotalIncome
    FROM Income
    WHERE UserID = p_UserID
      AND MONTH(IncomeDate) = p_Month
      AND YEAR(IncomeDate) = p_Year;

    RETURN v_TotalIncome;
END$$

-- =====================================================
-- 2. Function: fn_total_expense
-- Returns total expense of a user in a specific month and year
-- =====================================================
CREATE FUNCTION fn_total_expense(
    p_UserID INT,
    p_Month INT,
    p_Year INT
)
RETURNS DECIMAL(15,2)
READS SQL DATA
BEGIN
    DECLARE v_TotalExpense DECIMAL(15,2);

    SELECT COALESCE(SUM(Amount), 0)
    INTO v_TotalExpense
    FROM Expenses
    WHERE UserID = p_UserID
      AND MONTH(ExpenseDate) = p_Month
      AND YEAR(ExpenseDate) = p_Year;

    RETURN v_TotalExpense;
END$$

-- =====================================================
-- 3. Function: fn_net_savings
-- Returns net savings = total income - total expense
-- =====================================================
CREATE FUNCTION fn_net_savings(
    p_UserID INT,
    p_Month INT,
    p_Year INT
)
RETURNS DECIMAL(15,2)
READS SQL DATA
BEGIN
    DECLARE v_Savings DECIMAL(15,2);

    SET v_Savings = fn_total_income(p_UserID, p_Month, p_Year)
                  - fn_total_expense(p_UserID, p_Month, p_Year);

    RETURN v_Savings;
END$$

-- =====================================================
-- 4. Function: fn_budget_status
-- Returns budget status for a user, category, month, and year
-- SAFE: spending < 80% of budget
-- WARNING: spending >= 80% of budget
-- OVER_BUDGET: spending > budget
-- =====================================================
CREATE FUNCTION fn_budget_status(
    p_UserID INT,
    p_CategoryID INT,
    p_Month INT,
    p_Year INT
)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_LimitAmount DECIMAL(15,2);
    DECLARE v_ActualSpent DECIMAL(15,2);
    DECLARE v_Status VARCHAR(20);

    SELECT LimitAmount
    INTO v_LimitAmount
    FROM Budgets
    WHERE UserID = p_UserID
      AND CategoryID = p_CategoryID
      AND Month = p_Month
      AND Year = p_Year
    LIMIT 1;

    SELECT COALESCE(SUM(Amount), 0)
    INTO v_ActualSpent
    FROM Expenses
    WHERE UserID = p_UserID
      AND CategoryID = p_CategoryID
      AND MONTH(ExpenseDate) = p_Month
      AND YEAR(ExpenseDate) = p_Year;

    IF v_LimitAmount IS NULL THEN
        SET v_Status = 'NO_BUDGET';
    ELSEIF v_ActualSpent > v_LimitAmount THEN
        SET v_Status = 'OVER_BUDGET';
    ELSEIF v_ActualSpent >= v_LimitAmount * 0.8 THEN
        SET v_Status = 'WARNING';
    ELSE
        SET v_Status = 'SAFE';
    END IF;

    RETURN v_Status;
END$$

DELIMITER ;

-- =====================================================
-- Test functions
-- =====================================================

-- User 1, April 2026
SELECT fn_total_income(1, 4, 2026) AS User1_April_TotalIncome;
SELECT fn_total_expense(1, 4, 2026) AS User1_April_TotalExpense;
SELECT fn_net_savings(1, 4, 2026) AS User1_April_NetSavings;

-- User 1, Food category, April 2026
SELECT fn_budget_status(1, 1, 4, 2026) AS User1_April_FoodBudgetStatus;

-- User 2, April 2026
SELECT fn_total_income(2, 4, 2026) AS User2_April_TotalIncome;
SELECT fn_total_expense(2, 4, 2026) AS User2_April_TotalExpense;
SELECT fn_net_savings(2, 4, 2026) AS User2_April_NetSavings;

-- User 2, Shopping category, April 2026
SELECT fn_budget_status(2, 6, 4, 2026) AS User2_April_ShoppingBudgetStatus;