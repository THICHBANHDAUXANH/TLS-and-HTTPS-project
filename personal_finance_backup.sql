-- MySQL dump 10.13  Distrib 8.4.7, for Win64 (x86_64)
--
-- Host: localhost    Database: personal_finance_db
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounts` (
  `AccountID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `AccountName` varchar(100) NOT NULL,
  `AccountType` enum('BANK','CASH','EWALLET') NOT NULL,
  `Balance` decimal(15,2) NOT NULL DEFAULT '0.00',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`AccountID`),
  KEY `idx_accounts_user` (`UserID`),
  KEY `idx_accounts_type` (`AccountType`),
  CONSTRAINT `fk_accounts_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `chk_account_balance` CHECK ((`Balance` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,1,'Duy Anh Bank Account','BANK',19000000.00,'2026-04-25 07:30:51'),(2,1,'Duy Anh Cash Wallet','CASH',1250000.00,'2026-04-25 07:30:51'),(3,2,'Minh Quan Bank Account','BANK',14200000.00,'2026-04-25 07:30:51'),(4,2,'Minh Quan Cash Wallet','CASH',950000.00,'2026-04-25 07:30:51');
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `balancehistory`
--

DROP TABLE IF EXISTS `balancehistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `balancehistory` (
  `HistoryID` int NOT NULL AUTO_INCREMENT,
  `AccountID` int NOT NULL,
  `ChangeAmount` decimal(15,2) NOT NULL,
  `BalanceAfter` decimal(15,2) NOT NULL,
  `ChangeType` enum('INCOME','EXPENSE') NOT NULL,
  `ChangeDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ReferenceID` int DEFAULT NULL,
  PRIMARY KEY (`HistoryID`),
  KEY `idx_balance_history_account_date` (`AccountID`,`ChangeDate`),
  CONSTRAINT `fk_balance_account` FOREIGN KEY (`AccountID`) REFERENCES `accounts` (`AccountID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `balancehistory`
--

LOCK TABLES `balancehistory` WRITE;
/*!40000 ALTER TABLE `balancehistory` DISABLE KEYS */;
INSERT INTO `balancehistory` VALUES (1,1,12000000.00,12000000.00,'INCOME','2026-03-01 02:00:00',1),(2,1,-3500000.00,8500000.00,'EXPENSE','2026-03-03 03:00:00',2),(3,2,1000000.00,1000000.00,'INCOME','2026-03-05 02:30:00',2),(4,2,-120000.00,880000.00,'EXPENSE','2026-03-02 05:00:00',1),(5,1,12000000.00,20500000.00,'INCOME','2026-04-01 02:00:00',4),(6,1,-3500000.00,17000000.00,'EXPENSE','2026-04-03 03:00:00',17),(7,2,800000.00,1680000.00,'INCOME','2026-04-06 02:30:00',5),(8,2,-130000.00,1550000.00,'EXPENSE','2026-04-02 05:00:00',16),(9,3,10000000.00,10000000.00,'INCOME','2026-03-01 02:00:00',7),(10,3,-3000000.00,7000000.00,'EXPENSE','2026-03-03 03:00:00',32),(11,4,700000.00,700000.00,'INCOME','2026-03-07 02:30:00',8),(12,4,-100000.00,600000.00,'EXPENSE','2026-03-02 05:00:00',31),(13,3,10000000.00,17000000.00,'INCOME','2026-04-01 02:00:00',10),(14,3,-3000000.00,14000000.00,'EXPENSE','2026-04-03 03:00:00',47),(15,4,600000.00,1200000.00,'INCOME','2026-04-05 02:30:00',11),(16,4,-110000.00,1090000.00,'EXPENSE','2026-04-02 05:00:00',46),(17,1,500000.00,19000000.00,'INCOME','2026-04-25 09:08:56',13);
/*!40000 ALTER TABLE `balancehistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `budgets`
--

DROP TABLE IF EXISTS `budgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `budgets` (
  `BudgetID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `CategoryID` int NOT NULL,
  `Month` int NOT NULL,
  `Year` int NOT NULL,
  `LimitAmount` decimal(15,2) NOT NULL,
  PRIMARY KEY (`BudgetID`),
  UNIQUE KEY `uq_user_category_month_year` (`UserID`,`CategoryID`,`Month`,`Year`),
  KEY `fk_budget_category` (`CategoryID`),
  KEY `idx_budgets_user_category_month_year` (`UserID`,`CategoryID`,`Month`,`Year`),
  CONSTRAINT `fk_budget_category` FOREIGN KEY (`CategoryID`) REFERENCES `expensecategories` (`CategoryID`) ON DELETE CASCADE,
  CONSTRAINT `fk_budget_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `chk_budget_limit` CHECK ((`LimitAmount` > 0)),
  CONSTRAINT `chk_budget_month` CHECK ((`Month` between 1 and 12)),
  CONSTRAINT `chk_budget_year` CHECK ((`Year` >= 2000))
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `budgets`
--

LOCK TABLES `budgets` WRITE;
/*!40000 ALTER TABLE `budgets` DISABLE KEYS */;
INSERT INTO `budgets` VALUES (1,1,1,3,2026,1800000.00),(2,1,2,3,2026,600000.00),(3,1,3,3,2026,3500000.00),(4,1,4,3,2026,1000000.00),(5,1,6,3,2026,800000.00),(6,1,7,3,2026,400000.00),(7,1,8,3,2026,800000.00),(8,1,1,4,2026,1800000.00),(9,1,2,4,2026,700000.00),(10,1,3,4,2026,3500000.00),(11,1,4,4,2026,1000000.00),(12,1,6,4,2026,900000.00),(13,1,7,4,2026,400000.00),(14,1,8,4,2026,800000.00),(15,2,1,3,2026,1600000.00),(16,2,2,3,2026,500000.00),(17,2,3,3,2026,3000000.00),(18,2,4,3,2026,800000.00),(19,2,6,3,2026,700000.00),(20,2,7,3,2026,300000.00),(21,2,8,3,2026,700000.00),(22,2,1,4,2026,1600000.00),(23,2,2,4,2026,600000.00),(24,2,3,4,2026,3000000.00),(25,2,4,4,2026,800000.00),(26,2,6,4,2026,800000.00),(27,2,7,4,2026,300000.00),(28,2,8,4,2026,700000.00);
/*!40000 ALTER TABLE `budgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expensecategories`
--

DROP TABLE IF EXISTS `expensecategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expensecategories` (
  `CategoryID` int NOT NULL AUTO_INCREMENT,
  `CategoryName` varchar(100) NOT NULL,
  PRIMARY KEY (`CategoryID`),
  UNIQUE KEY `CategoryName` (`CategoryName`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expensecategories`
--

LOCK TABLES `expensecategories` WRITE;
/*!40000 ALTER TABLE `expensecategories` DISABLE KEYS */;
INSERT INTO `expensecategories` VALUES (4,'Education'),(7,'Entertainment'),(1,'Food'),(5,'Healthcare'),(10,'Other'),(3,'Rent'),(9,'Savings'),(6,'Shopping'),(2,'Transport'),(8,'Utilities');
/*!40000 ALTER TABLE `expensecategories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `ExpenseID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `AccountID` int NOT NULL,
  `CategoryID` int NOT NULL,
  `Amount` decimal(15,2) NOT NULL,
  `ExpenseDate` date NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ExpenseID`),
  KEY `idx_expenses_user_date` (`UserID`,`ExpenseDate`),
  KEY `idx_expenses_category` (`CategoryID`),
  KEY `idx_expenses_account` (`AccountID`),
  KEY `idx_expenses_user_category_date` (`UserID`,`CategoryID`,`ExpenseDate`),
  CONSTRAINT `fk_expense_account` FOREIGN KEY (`AccountID`) REFERENCES `accounts` (`AccountID`) ON DELETE CASCADE,
  CONSTRAINT `fk_expense_category` FOREIGN KEY (`CategoryID`) REFERENCES `expensecategories` (`CategoryID`) ON DELETE RESTRICT,
  CONSTRAINT `fk_expense_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `chk_expense_amount` CHECK ((`Amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
INSERT INTO `expenses` VALUES (1,1,2,1,120000.00,'2026-03-02','Breakfast and lunch','2026-04-25 07:30:51'),(2,1,1,3,3500000.00,'2026-03-03','Monthly room rent','2026-04-25 07:30:51'),(3,1,2,2,50000.00,'2026-03-04','Bus ticket','2026-04-25 07:30:51'),(4,1,1,8,450000.00,'2026-03-05','Electricity bill','2026-04-25 07:30:51'),(5,1,2,1,90000.00,'2026-03-06','Coffee and snacks','2026-04-25 07:30:51'),(6,1,1,4,650000.00,'2026-03-07','Online course','2026-04-25 07:30:51'),(7,1,2,2,70000.00,'2026-03-08','Taxi','2026-04-25 07:30:51'),(8,1,1,6,780000.00,'2026-03-10','Clothes','2026-04-25 07:30:51'),(9,1,2,1,150000.00,'2026-03-11','Dinner','2026-04-25 07:30:51'),(10,1,1,7,250000.00,'2026-03-12','Movie ticket','2026-04-25 07:30:51'),(11,1,1,5,300000.00,'2026-03-14','Medicine','2026-04-25 07:30:51'),(12,1,2,1,110000.00,'2026-03-16','Lunch','2026-04-25 07:30:51'),(13,1,1,8,300000.00,'2026-03-18','Internet bill','2026-04-25 07:30:51'),(14,1,2,10,85000.00,'2026-03-20','Personal item','2026-04-25 07:30:51'),(15,1,1,9,1500000.00,'2026-03-25','Transfer to savings','2026-04-25 07:30:51'),(16,1,2,1,130000.00,'2026-04-02','Breakfast and lunch','2026-04-25 07:30:51'),(17,1,1,3,3500000.00,'2026-04-03','Monthly room rent','2026-04-25 07:30:51'),(18,1,2,2,60000.00,'2026-04-04','Bus ticket','2026-04-25 07:30:51'),(19,1,1,8,520000.00,'2026-04-05','Electricity bill','2026-04-25 07:30:51'),(20,1,2,1,95000.00,'2026-04-06','Coffee','2026-04-25 07:30:51'),(21,1,1,4,850000.00,'2026-04-08','Study materials','2026-04-25 07:30:51'),(22,1,2,2,120000.00,'2026-04-09','Grab bike','2026-04-25 07:30:51'),(23,1,1,6,950000.00,'2026-04-10','New shoes','2026-04-25 07:30:51'),(24,1,2,1,170000.00,'2026-04-12','Dinner with friends','2026-04-25 07:30:51'),(25,1,1,7,350000.00,'2026-04-13','Entertainment','2026-04-25 07:30:51'),(26,1,1,5,420000.00,'2026-04-15','Health check','2026-04-25 07:30:51'),(27,1,2,1,125000.00,'2026-04-17','Lunch','2026-04-25 07:30:51'),(28,1,1,8,320000.00,'2026-04-18','Internet bill','2026-04-25 07:30:51'),(29,1,2,10,100000.00,'2026-04-21','Small personal expense','2026-04-25 07:30:51'),(30,1,1,9,2000000.00,'2026-04-25','Transfer to savings','2026-04-25 07:30:51'),(31,2,4,1,100000.00,'2026-03-02','Lunch','2026-04-25 07:30:51'),(32,2,3,3,3000000.00,'2026-03-03','Rent','2026-04-25 07:30:51'),(33,2,4,2,40000.00,'2026-03-04','Bus ticket','2026-04-25 07:30:51'),(34,2,3,8,400000.00,'2026-03-05','Electricity bill','2026-04-25 07:30:51'),(35,2,4,1,80000.00,'2026-03-06','Coffee','2026-04-25 07:30:51'),(36,2,3,4,500000.00,'2026-03-08','Book purchase','2026-04-25 07:30:51'),(37,2,4,2,90000.00,'2026-03-09','Taxi','2026-04-25 07:30:51'),(38,2,3,6,650000.00,'2026-03-10','Clothing','2026-04-25 07:30:51'),(39,2,4,1,130000.00,'2026-03-12','Dinner','2026-04-25 07:30:51'),(40,2,3,7,200000.00,'2026-03-13','Game subscription','2026-04-25 07:30:51'),(41,2,3,5,250000.00,'2026-03-15','Medicine','2026-04-25 07:30:51'),(42,2,4,1,90000.00,'2026-03-17','Lunch','2026-04-25 07:30:51'),(43,2,3,8,280000.00,'2026-03-19','Internet bill','2026-04-25 07:30:51'),(44,2,4,10,75000.00,'2026-03-20','Other expense','2026-04-25 07:30:51'),(45,2,3,9,1200000.00,'2026-03-26','Savings deposit','2026-04-25 07:30:51'),(46,2,4,1,110000.00,'2026-04-02','Lunch','2026-04-25 07:30:51'),(47,2,3,3,3000000.00,'2026-04-03','Rent','2026-04-25 07:30:51'),(48,2,4,2,50000.00,'2026-04-04','Bus ticket','2026-04-25 07:30:51'),(49,2,3,8,430000.00,'2026-04-05','Electricity bill','2026-04-25 07:30:51'),(50,2,4,1,95000.00,'2026-04-06','Coffee','2026-04-25 07:30:51'),(51,2,3,4,700000.00,'2026-04-08','Online course','2026-04-25 07:30:51'),(52,2,4,2,95000.00,'2026-04-09','Taxi','2026-04-25 07:30:51'),(53,2,3,6,850000.00,'2026-04-11','Shopping','2026-04-25 07:30:51'),(54,2,4,1,160000.00,'2026-04-12','Dinner','2026-04-25 07:30:51'),(55,2,3,7,300000.00,'2026-04-14','Entertainment','2026-04-25 07:30:51'),(56,2,3,5,350000.00,'2026-04-16','Medical expense','2026-04-25 07:30:51'),(57,2,4,1,100000.00,'2026-04-18','Lunch','2026-04-25 07:30:51'),(58,2,3,8,300000.00,'2026-04-19','Internet bill','2026-04-25 07:30:51'),(59,2,4,10,90000.00,'2026-04-21','Other expense','2026-04-25 07:30:51'),(60,2,3,9,1500000.00,'2026-04-26','Savings deposit','2026-04-25 07:30:51');
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_before_expense_insert` BEFORE INSERT ON `expenses` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_after_expense_insert` AFTER INSERT ON `expenses` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `income`
--

DROP TABLE IF EXISTS `income`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `income` (
  `IncomeID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `AccountID` int NOT NULL,
  `Amount` decimal(15,2) NOT NULL,
  `IncomeDate` date NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`IncomeID`),
  KEY `idx_income_user_date` (`UserID`,`IncomeDate`),
  KEY `idx_income_account` (`AccountID`),
  CONSTRAINT `fk_income_account` FOREIGN KEY (`AccountID`) REFERENCES `accounts` (`AccountID`) ON DELETE CASCADE,
  CONSTRAINT `fk_income_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `chk_income_amount` CHECK ((`Amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `income`
--

LOCK TABLES `income` WRITE;
/*!40000 ALTER TABLE `income` DISABLE KEYS */;
INSERT INTO `income` VALUES (1,1,1,12000000.00,'2026-03-01','Monthly salary - March','2026-04-25 07:30:51'),(2,1,2,1000000.00,'2026-03-05','Cash allowance','2026-04-25 07:30:51'),(3,1,1,2000000.00,'2026-03-18','Freelance project payment','2026-04-25 07:30:51'),(4,1,1,12000000.00,'2026-04-01','Monthly salary - April','2026-04-25 07:30:51'),(5,1,2,800000.00,'2026-04-06','Cash bonus','2026-04-25 07:30:51'),(6,1,1,1500000.00,'2026-04-20','Part-time income','2026-04-25 07:30:51'),(7,2,3,10000000.00,'2026-03-01','Monthly salary - March','2026-04-25 07:30:51'),(8,2,4,700000.00,'2026-03-07','Cash allowance','2026-04-25 07:30:51'),(9,2,3,1200000.00,'2026-03-22','Freelance income','2026-04-25 07:30:51'),(10,2,3,10000000.00,'2026-04-01','Monthly salary - April','2026-04-25 07:30:51'),(11,2,4,600000.00,'2026-04-05','Cash gift','2026-04-25 07:30:51'),(12,2,3,1800000.00,'2026-04-19','Side project payment','2026-04-25 07:30:51'),(13,1,1,500000.00,'2026-04-28','Extra income for testing','2026-04-25 09:08:56');
/*!40000 ALTER TABLE `income` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_before_income_insert` BEFORE INSERT ON `income` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_after_income_insert` AFTER INSERT ON `income` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `UserName` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `PhoneNumber` varchar(20) DEFAULT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Nguyen Duy Anh','duyanh@example.com','0912345678','hashed_password_1','2026-04-25 07:30:51'),(2,'Tran Minh Quan','minhquan@example.com','0987654321','hashed_password_2','2026-04-25 07:30:51');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_account_balance_summary`
--

DROP TABLE IF EXISTS `vw_account_balance_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_account_balance_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_account_balance_summary` AS SELECT 
 1 AS `AccountID`,
 1 AS `UserID`,
 1 AS `UserName`,
 1 AS `AccountName`,
 1 AS `AccountType`,
 1 AS `Balance`,
 1 AS `CreatedAt`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_budget_status`
--

DROP TABLE IF EXISTS `vw_budget_status`;
/*!50001 DROP VIEW IF EXISTS `vw_budget_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_budget_status` AS SELECT 
 1 AS `BudgetID`,
 1 AS `UserID`,
 1 AS `UserName`,
 1 AS `CategoryID`,
 1 AS `CategoryName`,
 1 AS `Year`,
 1 AS `Month`,
 1 AS `LimitAmount`,
 1 AS `ActualSpent`,
 1 AS `RemainingAmount`,
 1 AS `BudgetStatus`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_category_wise_spending`
--

DROP TABLE IF EXISTS `vw_category_wise_spending`;
/*!50001 DROP VIEW IF EXISTS `vw_category_wise_spending`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_category_wise_spending` AS SELECT 
 1 AS `UserID`,
 1 AS `UserName`,
 1 AS `Year`,
 1 AS `Month`,
 1 AS `CategoryID`,
 1 AS `CategoryName`,
 1 AS `NumberOfTransactions`,
 1 AS `TotalSpent`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_monthly_financial_summary`
--

DROP TABLE IF EXISTS `vw_monthly_financial_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_monthly_financial_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_monthly_financial_summary` AS SELECT 
 1 AS `UserID`,
 1 AS `UserName`,
 1 AS `Year`,
 1 AS `Month`,
 1 AS `TotalIncome`,
 1 AS `TotalExpense`,
 1 AS `Savings`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_transaction_history`
--

DROP TABLE IF EXISTS `vw_transaction_history`;
/*!50001 DROP VIEW IF EXISTS `vw_transaction_history`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_transaction_history` AS SELECT 
 1 AS `TransactionID`,
 1 AS `UserID`,
 1 AS `UserName`,
 1 AS `AccountID`,
 1 AS `AccountName`,
 1 AS `AccountType`,
 1 AS `TransactionType`,
 1 AS `CategoryName`,
 1 AS `Amount`,
 1 AS `SignedAmount`,
 1 AS `TransactionDate`,
 1 AS `Description`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_account_balance_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_account_balance_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_account_balance_summary` AS select `a`.`AccountID` AS `AccountID`,`a`.`UserID` AS `UserID`,`u`.`UserName` AS `UserName`,`a`.`AccountName` AS `AccountName`,`a`.`AccountType` AS `AccountType`,`a`.`Balance` AS `Balance`,`a`.`CreatedAt` AS `CreatedAt` from (`accounts` `a` join `users` `u` on((`a`.`UserID` = `u`.`UserID`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_budget_status`
--

/*!50001 DROP VIEW IF EXISTS `vw_budget_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_budget_status` AS select `b`.`BudgetID` AS `BudgetID`,`b`.`UserID` AS `UserID`,`u`.`UserName` AS `UserName`,`b`.`CategoryID` AS `CategoryID`,`c`.`CategoryName` AS `CategoryName`,`b`.`Year` AS `Year`,`b`.`Month` AS `Month`,`b`.`LimitAmount` AS `LimitAmount`,coalesce(sum(`e`.`Amount`),0) AS `ActualSpent`,(`b`.`LimitAmount` - coalesce(sum(`e`.`Amount`),0)) AS `RemainingAmount`,(case when (coalesce(sum(`e`.`Amount`),0) > `b`.`LimitAmount`) then 'OVER_BUDGET' when (coalesce(sum(`e`.`Amount`),0) >= (`b`.`LimitAmount` * 0.8)) then 'WARNING' else 'SAFE' end) AS `BudgetStatus` from (((`budgets` `b` join `users` `u` on((`b`.`UserID` = `u`.`UserID`))) join `expensecategories` `c` on((`b`.`CategoryID` = `c`.`CategoryID`))) left join `expenses` `e` on(((`b`.`UserID` = `e`.`UserID`) and (`b`.`CategoryID` = `e`.`CategoryID`) and (`b`.`Year` = year(`e`.`ExpenseDate`)) and (`b`.`Month` = month(`e`.`ExpenseDate`))))) group by `b`.`BudgetID`,`b`.`UserID`,`u`.`UserName`,`b`.`CategoryID`,`c`.`CategoryName`,`b`.`Year`,`b`.`Month`,`b`.`LimitAmount` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_category_wise_spending`
--

/*!50001 DROP VIEW IF EXISTS `vw_category_wise_spending`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_category_wise_spending` AS select `e`.`UserID` AS `UserID`,`u`.`UserName` AS `UserName`,year(`e`.`ExpenseDate`) AS `Year`,month(`e`.`ExpenseDate`) AS `Month`,`c`.`CategoryID` AS `CategoryID`,`c`.`CategoryName` AS `CategoryName`,count(`e`.`ExpenseID`) AS `NumberOfTransactions`,sum(`e`.`Amount`) AS `TotalSpent` from ((`expenses` `e` join `users` `u` on((`e`.`UserID` = `u`.`UserID`))) join `expensecategories` `c` on((`e`.`CategoryID` = `c`.`CategoryID`))) group by `e`.`UserID`,`u`.`UserName`,year(`e`.`ExpenseDate`),month(`e`.`ExpenseDate`),`c`.`CategoryID`,`c`.`CategoryName` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_monthly_financial_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_monthly_financial_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_monthly_financial_summary` AS select `u`.`UserID` AS `UserID`,`u`.`UserName` AS `UserName`,`ym`.`Year` AS `Year`,`ym`.`Month` AS `Month`,coalesce(`i`.`TotalIncome`,0) AS `TotalIncome`,coalesce(`e`.`TotalExpense`,0) AS `TotalExpense`,(coalesce(`i`.`TotalIncome`,0) - coalesce(`e`.`TotalExpense`,0)) AS `Savings` from (((`users` `u` join (select `income`.`UserID` AS `UserID`,year(`income`.`IncomeDate`) AS `Year`,month(`income`.`IncomeDate`) AS `Month` from `income` union select `expenses`.`UserID` AS `UserID`,year(`expenses`.`ExpenseDate`) AS `Year`,month(`expenses`.`ExpenseDate`) AS `Month` from `expenses`) `ym` on((`u`.`UserID` = `ym`.`UserID`))) left join (select `income`.`UserID` AS `UserID`,year(`income`.`IncomeDate`) AS `Year`,month(`income`.`IncomeDate`) AS `Month`,sum(`income`.`Amount`) AS `TotalIncome` from `income` group by `income`.`UserID`,year(`income`.`IncomeDate`),month(`income`.`IncomeDate`)) `i` on(((`ym`.`UserID` = `i`.`UserID`) and (`ym`.`Year` = `i`.`Year`) and (`ym`.`Month` = `i`.`Month`)))) left join (select `expenses`.`UserID` AS `UserID`,year(`expenses`.`ExpenseDate`) AS `Year`,month(`expenses`.`ExpenseDate`) AS `Month`,sum(`expenses`.`Amount`) AS `TotalExpense` from `expenses` group by `expenses`.`UserID`,year(`expenses`.`ExpenseDate`),month(`expenses`.`ExpenseDate`)) `e` on(((`ym`.`UserID` = `e`.`UserID`) and (`ym`.`Year` = `e`.`Year`) and (`ym`.`Month` = `e`.`Month`)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_transaction_history`
--

/*!50001 DROP VIEW IF EXISTS `vw_transaction_history`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_transaction_history` AS select `i`.`IncomeID` AS `TransactionID`,`i`.`UserID` AS `UserID`,`u`.`UserName` AS `UserName`,`i`.`AccountID` AS `AccountID`,`a`.`AccountName` AS `AccountName`,`a`.`AccountType` AS `AccountType`,'INCOME' AS `TransactionType`,'Income' AS `CategoryName`,`i`.`Amount` AS `Amount`,`i`.`Amount` AS `SignedAmount`,`i`.`IncomeDate` AS `TransactionDate`,`i`.`Description` AS `Description` from ((`income` `i` join `users` `u` on((`i`.`UserID` = `u`.`UserID`))) join `accounts` `a` on((`i`.`AccountID` = `a`.`AccountID`))) union all select `e`.`ExpenseID` AS `TransactionID`,`e`.`UserID` AS `UserID`,`u`.`UserName` AS `UserName`,`e`.`AccountID` AS `AccountID`,`a`.`AccountName` AS `AccountName`,`a`.`AccountType` AS `AccountType`,'EXPENSE' AS `TransactionType`,`c`.`CategoryName` AS `CategoryName`,`e`.`Amount` AS `Amount`,-(`e`.`Amount`) AS `SignedAmount`,`e`.`ExpenseDate` AS `TransactionDate`,`e`.`Description` AS `Description` from (((`expenses` `e` join `users` `u` on((`e`.`UserID` = `u`.`UserID`))) join `accounts` `a` on((`e`.`AccountID` = `a`.`AccountID`))) join `expensecategories` `c` on((`e`.`CategoryID` = `c`.`CategoryID`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-25 16:19:59
