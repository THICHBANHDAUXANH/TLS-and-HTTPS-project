-- =====================================================
-- File: 06_procedures.sql
-- Project: Personal Finance Management System
-- Purpose: Create stored procedures for common operations
-- =====================================================

USE personal_finance_db;

-- =====================================================
-- Drop existing procedures if they already exist
-- =====================================================
DROP PROCEDURE IF EXISTS sp_add_income;
DROP PROCEDURE IF EXISTS sp_add_expense;
DROP PROCEDURE IF EXISTS sp_get_monthly_summary;
DROP PROCEDURE IF EXISTS sp_get_category_spending;
DROP PROCEDURE IF EXISTS sp_get_budget_status;
DROP PROCEDURE IF EXISTS sp_get_transaction_history;

DELIMITER $$

-- =====================================================
-- 1. Procedure: sp_add_income
-- Adds a new income record.
-- Balance update will be handled by trigger later.
-- =====================================================
CREATE PROCEDURE sp_add_income(
    IN p_UserID INT,
    IN p_AccountID INT,
    IN p_Amount DECIMAL(15,2),
    IN p_IncomeDate DATE,
    IN p_Description VARCHAR(255)
)
BEGIN
    DECLARE v_AccountCount INT;

    IF p_Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Income amount must be greater than zero.';
    END IF;

    SELECT COUNT(*)
    INTO v_AccountCount
    FROM Accounts
    WHERE AccountID = p_AccountID
      AND UserID = p_UserID;

    IF v_AccountCount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid account for this user.';
    END IF;

    INSERT INTO Income (UserID, AccountID, Amount, IncomeDate, Description)
    VALUES (p_UserID, p_AccountID, p_Amount, p_IncomeDate, p_Description);
END$$

-- =====================================================
-- 2. Procedure: sp_add_expense
-- Adds a new expense record.
-- It checks account ownership, category existence, and balance.
-- Balance update will be handled by trigger later.
-- =====================================================
CREATE PROCEDURE sp_add_expense(
    IN p_UserID INT,
    IN p_AccountID INT,
    IN p_CategoryID INT,
    IN p_Amount DECIMAL(15,2),
    IN p_ExpenseDate DATE,
    IN p_Description VARCHAR(255)
)
BEGIN
    DECLARE v_AccountCount INT;
    DECLARE v_CategoryCount INT;
    DECLARE v_CurrentBalance DECIMAL(15,2);

    IF p_Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expense amount must be greater than zero.';
    END IF;

    SELECT COUNT(*)
    INTO v_AccountCount
    FROM Accounts
    WHERE AccountID = p_AccountID
      AND UserID = p_UserID;

    IF v_AccountCount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid account for this user.';
    END IF;

    SELECT COUNT(*)
    INTO v_CategoryCount
    FROM ExpenseCategories
    WHERE CategoryID = p_CategoryID;

    IF v_CategoryCount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid expense category.';
    END IF;

    SELECT Balance
    INTO v_CurrentBalance
    FROM Accounts
    WHERE AccountID = p_AccountID;

    IF v_CurrentBalance < p_Amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient account balance.';
    END IF;

    INSERT INTO Expenses (UserID, AccountID, CategoryID, Amount, ExpenseDate, Description)
    VALUES (p_UserID, p_AccountID, p_CategoryID, p_Amount, p_ExpenseDate, p_Description);
END$$

-- =====================================================
-- 3. Procedure: sp_get_monthly_summary
-- Returns monthly income, expense, and savings.
-- =====================================================
CREATE PROCEDURE sp_get_monthly_summary(
    IN p_UserID INT,
    IN p_Month INT,
    IN p_Year INT
)
BEGIN
    SELECT
        u.UserID,
        u.UserName,
        p_Year AS Year,
        p_Month AS Month,
        fn_total_income(p_UserID, p_Month, p_Year) AS TotalIncome,
        fn_total_expense(p_UserID, p_Month, p_Year) AS TotalExpense,
        fn_net_savings(p_UserID, p_Month, p_Year) AS NetSavings
    FROM Users u
    WHERE u.UserID = p_UserID;
END$$

-- =====================================================
-- 4. Procedure: sp_get_category_spending
-- Returns category-wise spending of a user in a selected month.
-- =====================================================
CREATE PROCEDURE sp_get_category_spending(
    IN p_UserID INT,
    IN p_Month INT,
    IN p_Year INT
)
BEGIN
    SELECT
        UserID,
        UserName,
        Year,
        Month,
        CategoryID,
        CategoryName,
        NumberOfTransactions,
        TotalSpent
    FROM vw_category_wise_spending
    WHERE UserID = p_UserID
      AND Month = p_Month
      AND Year = p_Year
    ORDER BY TotalSpent DESC;
END$$

-- =====================================================
-- 5. Procedure: sp_get_budget_status
-- Returns budget status of a user in a selected month.
-- =====================================================
CREATE PROCEDURE sp_get_budget_status(
    IN p_UserID INT,
    IN p_Month INT,
    IN p_Year INT
)
BEGIN
    SELECT
        BudgetID,
        UserID,
        UserName,
        CategoryID,
        CategoryName,
        Year,
        Month,
        LimitAmount,
        ActualSpent,
        RemainingAmount,
        BudgetStatus
    FROM vw_budget_status
    WHERE UserID = p_UserID
      AND Month = p_Month
      AND Year = p_Year
    ORDER BY CategoryID;
END$$

-- =====================================================
-- 6. Procedure: sp_get_transaction_history
-- Returns income and expense transactions.
-- If p_AccountID is NULL, it returns all accounts of the user.
-- =====================================================
CREATE PROCEDURE sp_get_transaction_history(
    IN p_UserID INT,
    IN p_AccountID INT
)
BEGIN
    SELECT
        TransactionID,
        UserID,
        UserName,
        AccountID,
        AccountName,
        AccountType,
        TransactionType,
        CategoryName,
        Amount,
        SignedAmount,
        TransactionDate,
        Description
    FROM vw_transaction_history
    WHERE UserID = p_UserID
      AND (p_AccountID IS NULL OR AccountID = p_AccountID)
    ORDER BY TransactionDate DESC, TransactionType;
END$$

DELIMITER ;

-- =====================================================
-- Test procedures
-- =====================================================

-- Monthly summary for User 1 in April 2026
CALL sp_get_monthly_summary(1, 4, 2026);

-- Category-wise spending for User 1 in April 2026
CALL sp_get_category_spending(1, 4, 2026);

-- Budget status for User 1 in April 2026
CALL sp_get_budget_status(1, 4, 2026);

-- Transaction history for User 1, all accounts
CALL sp_get_transaction_history(1, NULL);

-- Transaction history for User 1, bank account only
CALL sp_get_transaction_history(1, 1);

-- Example insert commands.
-- These should be tested after creating triggers in 07_triggers.sql.
-- CALL sp_add_income(1, 1, 500000.00, '2026-04-28', 'Extra income');
-- CALL sp_add_expense(1, 2, 1, 50000.00, '2026-04-28', 'Snack');