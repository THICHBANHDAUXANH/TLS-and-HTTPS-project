-- =====================================================
-- File: 07_triggers.sql
-- Project: Personal Finance Management System
-- Purpose: Create triggers for automatic balance updates
-- =====================================================

USE personal_finance_db;

-- =====================================================
-- Drop existing triggers if they already exist
-- =====================================================
DROP TRIGGER IF EXISTS trg_before_income_insert;
DROP TRIGGER IF EXISTS trg_after_income_insert;
DROP TRIGGER IF EXISTS trg_before_expense_insert;
DROP TRIGGER IF EXISTS trg_after_expense_insert;

DELIMITER $$

-- =====================================================
-- 1. Trigger: trg_before_income_insert
-- Validate income before inserting
-- =====================================================
CREATE TRIGGER trg_before_income_insert
BEFORE INSERT ON Income
FOR EACH ROW
BEGIN
    DECLARE v_AccountOwner INT;

    -- Check income amount
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Income amount must be greater than zero.';
    END IF;

    -- Check whether the account belongs to the user
    SELECT UserID
    INTO v_AccountOwner
    FROM Accounts
    WHERE AccountID = NEW.AccountID;

    IF v_AccountOwner <> NEW.UserID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected account does not belong to this user.';
    END IF;
END$$

-- =====================================================
-- 2. Trigger: trg_after_income_insert
-- Automatically increase account balance after income insert
-- and record the change in BalanceHistory
-- =====================================================
CREATE TRIGGER trg_after_income_insert
AFTER INSERT ON Income
FOR EACH ROW
BEGIN
    UPDATE Accounts
    SET Balance = Balance + NEW.Amount
    WHERE AccountID = NEW.AccountID;

    INSERT INTO BalanceHistory (
        AccountID,
        ChangeAmount,
        BalanceAfter,
        ChangeType,
        ChangeDate,
        ReferenceID
    )
    VALUES (
        NEW.AccountID,
        NEW.Amount,
        (
            SELECT Balance
            FROM Accounts
            WHERE AccountID = NEW.AccountID
        ),
        'INCOME',
        NOW(),
        NEW.IncomeID
    );
END$$

-- =====================================================
-- 3. Trigger: trg_before_expense_insert
-- Validate expense before inserting
-- =====================================================
CREATE TRIGGER trg_before_expense_insert
BEFORE INSERT ON Expenses
FOR EACH ROW
BEGIN
    DECLARE v_AccountOwner INT;
    DECLARE v_CurrentBalance DECIMAL(15,2);

    -- Check expense amount
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expense amount must be greater than zero.';
    END IF;

    -- Check whether the account belongs to the user
    SELECT UserID, Balance
    INTO v_AccountOwner, v_CurrentBalance
    FROM Accounts
    WHERE AccountID = NEW.AccountID;

    IF v_AccountOwner <> NEW.UserID THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The selected account does not belong to this user.';
    END IF;

    -- Check sufficient balance
    IF v_CurrentBalance < NEW.Amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient account balance.';
    END IF;
END$$

-- =====================================================
-- 4. Trigger: trg_after_expense_insert
-- Automatically decrease account balance after expense insert
-- and record the change in BalanceHistory
-- =====================================================
CREATE TRIGGER trg_after_expense_insert
AFTER INSERT ON Expenses
FOR EACH ROW
BEGIN
    UPDATE Accounts
    SET Balance = Balance - NEW.Amount
    WHERE AccountID = NEW.AccountID;

    INSERT INTO BalanceHistory (
        AccountID,
        ChangeAmount,
        BalanceAfter,
        ChangeType,
        ChangeDate,
        ReferenceID
    )
    VALUES (
        NEW.AccountID,
        -NEW.Amount,
        (
            SELECT Balance
            FROM Accounts
            WHERE AccountID = NEW.AccountID
        ),
        'EXPENSE',
        NOW(),
        NEW.ExpenseID
    );
END$$

DELIMITER ;

-- =====================================================
-- Check created triggers
-- =====================================================
SHOW TRIGGERS;