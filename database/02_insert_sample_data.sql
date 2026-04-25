-- =====================================================
-- File: 02_insert_sample_data.sql
-- Project: Personal Finance Management System
-- Purpose: Insert sample users, accounts, transactions, budgets
-- =====================================================

USE personal_finance_db;

-- =====================================================
-- Clear old sample data
-- Use TRUNCATE instead of DELETE to avoid Safe Update Mode error
-- =====================================================
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE BalanceHistory;
TRUNCATE TABLE Budgets;
TRUNCATE TABLE Expenses;
TRUNCATE TABLE Income;
TRUNCATE TABLE Accounts;
TRUNCATE TABLE ExpenseCategories;
TRUNCATE TABLE Users;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 1. Users
-- =====================================================
INSERT INTO Users (UserID, UserName, Email, PhoneNumber, PasswordHash)
VALUES
(1, 'Nguyen Duy Anh', 'duyanh@example.com', '0912345678', 'hashed_password_1'),
(2, 'Tran Minh Quan', 'minhquan@example.com', '0987654321', 'hashed_password_2');

-- =====================================================
-- 2. Expense Categories
-- =====================================================
INSERT INTO ExpenseCategories (CategoryID, CategoryName)
VALUES
(1, 'Food'),
(2, 'Transport'),
(3, 'Rent'),
(4, 'Education'),
(5, 'Healthcare'),
(6, 'Shopping'),
(7, 'Entertainment'),
(8, 'Utilities'),
(9, 'Savings'),
(10, 'Other');

-- =====================================================
-- 3. Accounts
-- AccountType: BANK, CASH, EWALLET
-- =====================================================
INSERT INTO Accounts (AccountID, UserID, AccountName, AccountType, Balance)
VALUES
(1, 1, 'Duy Anh Bank Account', 'BANK', 18500000.00),
(2, 1, 'Duy Anh Cash Wallet', 'CASH', 1250000.00),
(3, 2, 'Minh Quan Bank Account', 'BANK', 14200000.00),
(4, 2, 'Minh Quan Cash Wallet', 'CASH', 950000.00);

-- =====================================================
-- 4. Income Records
-- =====================================================
INSERT INTO Income (IncomeID, UserID, AccountID, Amount, IncomeDate, Description)
VALUES
-- User 1: Duy Anh
(1, 1, 1, 12000000.00, '2026-03-01', 'Monthly salary - March'),
(2, 1, 2, 1000000.00,  '2026-03-05', 'Cash allowance'),
(3, 1, 1, 2000000.00,  '2026-03-18', 'Freelance project payment'),
(4, 1, 1, 12000000.00, '2026-04-01', 'Monthly salary - April'),
(5, 1, 2, 800000.00,   '2026-04-06', 'Cash bonus'),
(6, 1, 1, 1500000.00,  '2026-04-20', 'Part-time income'),

-- User 2: Minh Quan
(7, 2, 3, 10000000.00, '2026-03-01', 'Monthly salary - March'),
(8, 2, 4, 700000.00,   '2026-03-07', 'Cash allowance'),
(9, 2, 3, 1200000.00,  '2026-03-22', 'Freelance income'),
(10, 2, 3, 10000000.00, '2026-04-01', 'Monthly salary - April'),
(11, 2, 4, 600000.00,   '2026-04-05', 'Cash gift'),
(12, 2, 3, 1800000.00,  '2026-04-19', 'Side project payment');

-- =====================================================
-- 5. Expense Records
-- =====================================================
INSERT INTO Expenses (ExpenseID, UserID, AccountID, CategoryID, Amount, ExpenseDate, Description)
VALUES
-- User 1: Duy Anh - March 2026
(1, 1, 2, 1, 120000.00, '2026-03-02', 'Breakfast and lunch'),
(2, 1, 1, 3, 3500000.00, '2026-03-03', 'Monthly room rent'),
(3, 1, 2, 2, 50000.00, '2026-03-04', 'Bus ticket'),
(4, 1, 1, 8, 450000.00, '2026-03-05', 'Electricity bill'),
(5, 1, 2, 1, 90000.00, '2026-03-06', 'Coffee and snacks'),
(6, 1, 1, 4, 650000.00, '2026-03-07', 'Online course'),
(7, 1, 2, 2, 70000.00, '2026-03-08', 'Taxi'),
(8, 1, 1, 6, 780000.00, '2026-03-10', 'Clothes'),
(9, 1, 2, 1, 150000.00, '2026-03-11', 'Dinner'),
(10, 1, 1, 7, 250000.00, '2026-03-12', 'Movie ticket'),
(11, 1, 1, 5, 300000.00, '2026-03-14', 'Medicine'),
(12, 1, 2, 1, 110000.00, '2026-03-16', 'Lunch'),
(13, 1, 1, 8, 300000.00, '2026-03-18', 'Internet bill'),
(14, 1, 2, 10, 85000.00, '2026-03-20', 'Personal item'),
(15, 1, 1, 9, 1500000.00, '2026-03-25', 'Transfer to savings'),

-- User 1: Duy Anh - April 2026
(16, 1, 2, 1, 130000.00, '2026-04-02', 'Breakfast and lunch'),
(17, 1, 1, 3, 3500000.00, '2026-04-03', 'Monthly room rent'),
(18, 1, 2, 2, 60000.00, '2026-04-04', 'Bus ticket'),
(19, 1, 1, 8, 520000.00, '2026-04-05', 'Electricity bill'),
(20, 1, 2, 1, 95000.00, '2026-04-06', 'Coffee'),
(21, 1, 1, 4, 850000.00, '2026-04-08', 'Study materials'),
(22, 1, 2, 2, 120000.00, '2026-04-09', 'Grab bike'),
(23, 1, 1, 6, 950000.00, '2026-04-10', 'New shoes'),
(24, 1, 2, 1, 170000.00, '2026-04-12', 'Dinner with friends'),
(25, 1, 1, 7, 350000.00, '2026-04-13', 'Entertainment'),
(26, 1, 1, 5, 420000.00, '2026-04-15', 'Health check'),
(27, 1, 2, 1, 125000.00, '2026-04-17', 'Lunch'),
(28, 1, 1, 8, 320000.00, '2026-04-18', 'Internet bill'),
(29, 1, 2, 10, 100000.00, '2026-04-21', 'Small personal expense'),
(30, 1, 1, 9, 2000000.00, '2026-04-25', 'Transfer to savings'),

-- User 2: Minh Quan - March 2026
(31, 2, 4, 1, 100000.00, '2026-03-02', 'Lunch'),
(32, 2, 3, 3, 3000000.00, '2026-03-03', 'Rent'),
(33, 2, 4, 2, 40000.00, '2026-03-04', 'Bus ticket'),
(34, 2, 3, 8, 400000.00, '2026-03-05', 'Electricity bill'),
(35, 2, 4, 1, 80000.00, '2026-03-06', 'Coffee'),
(36, 2, 3, 4, 500000.00, '2026-03-08', 'Book purchase'),
(37, 2, 4, 2, 90000.00, '2026-03-09', 'Taxi'),
(38, 2, 3, 6, 650000.00, '2026-03-10', 'Clothing'),
(39, 2, 4, 1, 130000.00, '2026-03-12', 'Dinner'),
(40, 2, 3, 7, 200000.00, '2026-03-13', 'Game subscription'),
(41, 2, 3, 5, 250000.00, '2026-03-15', 'Medicine'),
(42, 2, 4, 1, 90000.00, '2026-03-17', 'Lunch'),
(43, 2, 3, 8, 280000.00, '2026-03-19', 'Internet bill'),
(44, 2, 4, 10, 75000.00, '2026-03-20', 'Other expense'),
(45, 2, 3, 9, 1200000.00, '2026-03-26', 'Savings deposit'),

-- User 2: Minh Quan - April 2026
(46, 2, 4, 1, 110000.00, '2026-04-02', 'Lunch'),
(47, 2, 3, 3, 3000000.00, '2026-04-03', 'Rent'),
(48, 2, 4, 2, 50000.00, '2026-04-04', 'Bus ticket'),
(49, 2, 3, 8, 430000.00, '2026-04-05', 'Electricity bill'),
(50, 2, 4, 1, 95000.00, '2026-04-06', 'Coffee'),
(51, 2, 3, 4, 700000.00, '2026-04-08', 'Online course'),
(52, 2, 4, 2, 95000.00, '2026-04-09', 'Taxi'),
(53, 2, 3, 6, 850000.00, '2026-04-11', 'Shopping'),
(54, 2, 4, 1, 160000.00, '2026-04-12', 'Dinner'),
(55, 2, 3, 7, 300000.00, '2026-04-14', 'Entertainment'),
(56, 2, 3, 5, 350000.00, '2026-04-16', 'Medical expense'),
(57, 2, 4, 1, 100000.00, '2026-04-18', 'Lunch'),
(58, 2, 3, 8, 300000.00, '2026-04-19', 'Internet bill'),
(59, 2, 4, 10, 90000.00, '2026-04-21', 'Other expense'),
(60, 2, 3, 9, 1500000.00, '2026-04-26', 'Savings deposit');

-- =====================================================
-- 6. Budgets
-- =====================================================
INSERT INTO Budgets (BudgetID, UserID, CategoryID, Month, Year, LimitAmount)
VALUES
-- User 1: March
(1, 1, 1, 3, 2026, 1800000.00),
(2, 1, 2, 3, 2026, 600000.00),
(3, 1, 3, 3, 2026, 3500000.00),
(4, 1, 4, 3, 2026, 1000000.00),
(5, 1, 6, 3, 2026, 800000.00),
(6, 1, 7, 3, 2026, 400000.00),
(7, 1, 8, 3, 2026, 800000.00),

-- User 1: April
(8, 1, 1, 4, 2026, 1800000.00),
(9, 1, 2, 4, 2026, 700000.00),
(10, 1, 3, 4, 2026, 3500000.00),
(11, 1, 4, 4, 2026, 1000000.00),
(12, 1, 6, 4, 2026, 900000.00),
(13, 1, 7, 4, 2026, 400000.00),
(14, 1, 8, 4, 2026, 800000.00),

-- User 2: March
(15, 2, 1, 3, 2026, 1600000.00),
(16, 2, 2, 3, 2026, 500000.00),
(17, 2, 3, 3, 2026, 3000000.00),
(18, 2, 4, 3, 2026, 800000.00),
(19, 2, 6, 3, 2026, 700000.00),
(20, 2, 7, 3, 2026, 300000.00),
(21, 2, 8, 3, 2026, 700000.00),

-- User 2: April
(22, 2, 1, 4, 2026, 1600000.00),
(23, 2, 2, 4, 2026, 600000.00),
(24, 2, 3, 4, 2026, 3000000.00),
(25, 2, 4, 4, 2026, 800000.00),
(26, 2, 6, 4, 2026, 800000.00),
(27, 2, 7, 4, 2026, 300000.00),
(28, 2, 8, 4, 2026, 700000.00);

-- =====================================================
-- 7. Balance History Samples
-- =====================================================
INSERT INTO BalanceHistory (HistoryID, AccountID, ChangeAmount, BalanceAfter, ChangeType, ChangeDate, ReferenceID)
VALUES
(1, 1, 12000000.00, 12000000.00, 'INCOME', '2026-03-01 09:00:00', 1),
(2, 1, -3500000.00, 8500000.00, 'EXPENSE', '2026-03-03 10:00:00', 2),
(3, 2, 1000000.00, 1000000.00, 'INCOME', '2026-03-05 09:30:00', 2),
(4, 2, -120000.00, 880000.00, 'EXPENSE', '2026-03-02 12:00:00', 1),

(5, 1, 12000000.00, 20500000.00, 'INCOME', '2026-04-01 09:00:00', 4),
(6, 1, -3500000.00, 17000000.00, 'EXPENSE', '2026-04-03 10:00:00', 17),
(7, 2, 800000.00, 1680000.00, 'INCOME', '2026-04-06 09:30:00', 5),
(8, 2, -130000.00, 1550000.00, 'EXPENSE', '2026-04-02 12:00:00', 16),

(9, 3, 10000000.00, 10000000.00, 'INCOME', '2026-03-01 09:00:00', 7),
(10, 3, -3000000.00, 7000000.00, 'EXPENSE', '2026-03-03 10:00:00', 32),
(11, 4, 700000.00, 700000.00, 'INCOME', '2026-03-07 09:30:00', 8),
(12, 4, -100000.00, 600000.00, 'EXPENSE', '2026-03-02 12:00:00', 31),

(13, 3, 10000000.00, 17000000.00, 'INCOME', '2026-04-01 09:00:00', 10),
(14, 3, -3000000.00, 14000000.00, 'EXPENSE', '2026-04-03 10:00:00', 47),
(15, 4, 600000.00, 1200000.00, 'INCOME', '2026-04-05 09:30:00', 11),
(16, 4, -110000.00, 1090000.00, 'EXPENSE', '2026-04-02 12:00:00', 46);

-- =====================================================
-- 8. Check inserted records
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