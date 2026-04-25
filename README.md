# Personal Finance Management System

## 1. Project Overview

The **Personal Finance Management System** is a database-driven web application designed to help users manage personal financial activities. The system allows users to record income, expenses, financial accounts, expense categories, budgets, and account balance history.

This project uses **MySQL** for database management and **Python Flask** for the web application. The main goal is to provide a simple and structured system that helps users track spending habits, monitor account balances, generate financial summaries, and receive budget alerts when spending exceeds planned limits.

---

## 2. Project Objectives

The main objectives of this project are:

- Manage user information and authentication.
- Record income and expense transactions.
- Classify expenses into categories.
- Support both bank and cash accounts.
- Automatically update account balances after transactions.
- Provide monthly financial summaries.
- Support budget planning and over-budget alerts.
- Generate reports for financial analysis.
- Demonstrate SQL features such as views, functions, procedures, triggers, indexes, and backup.

---

## 3. Main Features

### 3.1 User Management

The system supports user registration and login. User passwords are stored as hashed values instead of plain text for better security.

Main functions:

- Register new users.
- Log in with email and password.
- Store user session after login.
- Protect user-specific financial data.

### 3.2 Account Management

The system uses an `Accounts` table to store different types of financial accounts.

Supported account types:

- `BANK`
- `CASH`
- `EWALLET`

Examples:

- Bank account
- Cash wallet
- E-wallet account

Each account belongs to one user and has a current balance.

### 3.3 Income Management

Users can record income transactions. Each income transaction is linked to a specific account.

Examples of income:

- Monthly salary
- Freelance income
- Cash allowance
- Bonus

When a new income transaction is inserted, the system can automatically increase the account balance using triggers.

### 3.4 Expense Management

Users can record expense transactions. Each expense is linked to:

- A user
- An account
- An expense category

Examples of expense categories:

- Food
- Transport
- Rent
- Education
- Healthcare
- Shopping
- Entertainment
- Utilities
- Savings
- Other

When a new expense transaction is inserted, the system can automatically decrease the account balance using triggers.

### 3.5 Budget Management

Users can set monthly budgets for specific expense categories.

Examples:

- Food budget for April 2026: 1,800,000 VND
- Transport budget for April 2026: 700,000 VND

The system compares actual spending with the budget limit and returns one of the following statuses:

- `SAFE`
- `WARNING`
- `OVER_BUDGET`
- `NO_BUDGET`

### 3.6 Reports and Analysis

The system provides several financial reports, including:

- Monthly financial summary
- Category-wise spending report
- Budget status report
- Account balance summary
- Transaction history

These reports are created using SQL views, functions, and stored procedures.

---

## 4. Technology Stack

| Component | Technology |
|---|---|
| Database | MySQL |
| Database Tool | MySQL Workbench |
| Backend | Python Flask |
| Database Connector | mysql-connector-python |
| Authentication | Werkzeug password hashing |
| Frontend | HTML, CSS, Jinja2 Templates |
| Backup | mysqldump |

---

## 5. Project Structure

```text
Personal Finance Management/
|
|-- app.py
|-- config.py
|-- requirements.txt
|-- README.md
|
|-- database/
|   |-- 00_create_database.sql
|   |-- 01_create_tables.sql
|   |-- 02_insert_sample_data.sql
|   |-- 03_indexes.sql
|   |-- 04_views.sql
|   |-- 05_functions.sql
|   |-- 06_procedures.sql
|   |-- 07_triggers.sql
|   `-- 08_backup.sql
|
|-- services/
|   |-- db.py
|   |-- auth_service.py
|   |-- account_service.py
|   |-- income_service.py
|   |-- expense_service.py
|   |-- budget_service.py
|   `-- report_service.py
|
|-- templates/
|   |-- base.html
|   |-- login.html
|   |-- register.html
|   |-- dashboard.html
|   |-- accounts.html
|   |-- income.html
|   |-- expenses.html
|   |-- budgets.html
|   `-- reports.html
|
`-- static/
    `-- style.css
```

---

## 6. File Description

### 6.1 Main Application Files

#### app.py

This is the main Flask application file. It defines the routes of the web system.

Current and planned routes include:

- `/`
- `/login`
- `/register`
- `/dashboard`
- `/accounts`
- `/income`
- `/expenses`
- `/budgets`
- `/reports`
- `/logout`

It controls how users interact with the web application.

#### config.py

This file stores configuration settings for the project.

It contains:

- MySQL host
- MySQL port
- MySQL username
- MySQL password
- Database name
- Flask secret key

Example:

```python
DB_CONFIG = {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "root",
    "password": "YOUR_MYSQL_PASSWORD",
    "database": "personal_finance_db",
    "charset": "utf8mb4"
}

SECRET_KEY = "personal_finance_secret_key"
```

The `SECRET_KEY` is used by Flask to manage sessions securely.

#### requirements.txt

This file lists the Python libraries required to run the project.

Main libraries:

- Flask
- mysql-connector-python
- Werkzeug
- python-dotenv

Install them using:

```bash
pip install -r requirements.txt
```

---

## 7. Database Scripts

The `database/` folder contains all SQL scripts used to create and manage the database.

### 7.1 00_create_database.sql

Creates the database:

- `personal_finance_db`

This file also sets the character set to support Unicode data.

### 7.2 01_create_tables.sql

Creates all main tables:

- Users
- Accounts
- ExpenseCategories
- Income
- Expenses
- Budgets
- BalanceHistory

This script defines:

- Primary keys
- Foreign keys
- Check constraints
- Unique constraints
- Account type constraints

### 7.3 02_insert_sample_data.sql

Inserts sample data into the database.

The sample data includes:

- 2 users
- 4 accounts
- 10 expense categories
- 12 income records
- 60 expense records
- 28 budget records
- 16 balance history records

The sample data is designed to support financial reports for March and April 2026.

### 7.4 03_indexes.sql

Creates indexes to improve query performance.

Indexes are created on frequently queried columns such as:

- UserID
- AccountID
- CategoryID
- IncomeDate
- ExpenseDate
- AccountType

These indexes support faster reporting and filtering.

### 7.5 04_views.sql

Creates SQL views for reporting.

Main views:

- `vw_monthly_financial_summary`
- `vw_category_wise_spending`
- `vw_budget_status`
- `vw_account_balance_summary`
- `vw_transaction_history`

These views simplify report generation and dashboard display.

### 7.6 05_functions.sql

Creates user-defined SQL functions.

Main functions:

- `fn_total_income`
- `fn_total_expense`
- `fn_net_savings`
- `fn_budget_status`

These functions are used to calculate financial metrics.

### 7.7 06_procedures.sql

Creates stored procedures for common operations.

Main procedures:

- `sp_add_income`
- `sp_add_expense`
- `sp_get_monthly_summary`
- `sp_get_category_spending`
- `sp_get_budget_status`
- `sp_get_transaction_history`

These procedures help organize business logic inside the database.

### 7.8 07_triggers.sql

Creates triggers for automatic account balance updates.

Main triggers:

- `trg_before_income_insert`
- `trg_after_income_insert`
- `trg_before_expense_insert`
- `trg_after_expense_insert`

Trigger functions:

- Validate positive transaction amount.
- Check account ownership.
- Check sufficient balance before expense.
- Automatically update account balance.
- Insert balance changes into `BalanceHistory`.

### 7.9 08_backup.sql

Contains database backup and recovery instructions.

It includes:

- Checking current database
- Checking table list
- Checking record counts
- Backup command guide
- Restore command guide

The actual backup is performed using `mysqldump` in Command Prompt or Terminal.

Example backup command:

```powershell
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqldump.exe" -u root -p personal_finance_db > "D:\Self study\Kì 2 - Năm 2\Database\final\Project\Personal Finance Management\personal_finance_backup.sql"
```

---

## 8. Service Files

The `services/` folder is used to organize backend logic.

### 8.1 services/db.py

Creates and returns a MySQL database connection.

Main function:

- `get_connection()`

This function is used by other service files to interact with the database.

### 8.2 services/auth_service.py

Handles user authentication logic.

Planned functions:

- Register user
- Hash password
- Verify login
- Check existing email

### 8.3 services/account_service.py

Handles account-related operations.

Planned functions:

- Get user accounts
- Add new account
- Update account
- Delete account
- View balance history

### 8.4 services/income_service.py

Handles income-related operations.

Planned functions:

- Add income
- View income records
- Update income
- Delete income

### 8.5 services/expense_service.py

Handles expense-related operations.

Planned functions:

- Add expense
- View expense records
- Update expense
- Delete expense
- Filter expenses by category or date

### 8.6 services/budget_service.py

Handles budget-related operations.

Planned functions:

- Add monthly budget
- Update budget
- View budget status
- Detect over-budget categories

### 8.7 services/report_service.py

Handles reporting logic.

Planned functions:

- Monthly financial summary
- Category-wise spending
- Budget report
- Transaction history
- Dashboard data

---

## 9. Templates

The `templates/` folder stores HTML pages rendered by Flask.

### 9.1 base.html

The main layout template. Other pages extend this file.

It contains:

- Page header
- Navigation bar
- Flash message display
- Main content block

### 9.2 login.html

Login page for users.

Fields:

- Email
- Password

### 9.3 register.html

Registration page for new users.

Fields:

- Username
- Email
- Phone number
- Password

### 9.4 dashboard.html

Main dashboard page after login.

Planned dashboard content:

- Total income
- Total expenses
- Net savings
- Total balance
- Recent transactions
- Budget alerts

### 9.5 accounts.html

Page for managing financial accounts.

Planned features:

- View bank and cash accounts
- Add new account
- View account balance

### 9.6 income.html

Page for managing income records.

Planned features:

- Add income
- View income list
- Edit income
- Delete income

### 9.7 expenses.html

Page for managing expense records.

Planned features:

- Add expense
- View expense list
- Filter expenses by category/date
- Edit expense
- Delete expense

### 9.8 budgets.html

Page for managing monthly budgets.

Planned features:

- Set budget by category
- View budget status
- Show warning or over-budget alerts

### 9.9 reports.html

Page for financial reports.

Planned reports:

- Monthly income and expense summary
- Category-wise spending chart
- Budget status table
- Transaction history

---

## 10. How to Run the Project

### Step 1: Clone or Open the Project Folder

Open the project folder in VS Code or another code editor.

### Step 2: Install Python Dependencies

Run:

```bash
pip install -r requirements.txt
```

### Step 3: Configure MySQL Connection

Open `config.py` and update your MySQL password:

```python
DB_CONFIG = {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "root",
    "password": "YOUR_MYSQL_PASSWORD",
    "database": "personal_finance_db",
    "charset": "utf8mb4"
}
```

### Step 4: Create the Database

Open MySQL Workbench and run SQL scripts in this order:

1. `00_create_database.sql`
2. `01_create_tables.sql`
3. `02_insert_sample_data.sql`
4. `03_indexes.sql`
5. `04_views.sql`
6. `05_functions.sql`
7. `06_procedures.sql`
8. `07_triggers.sql`
9. `08_backup.sql`

The `08_backup.sql` file is optional for checking database status. The actual backup is done using `mysqldump`.

### Step 5: Run the Flask Application

Run:

```bash
python app.py
```

Then open your browser:

- `http://127.0.0.1:5000`

---

## 11. Demo Users

The sample data includes two users:

| User | Email | Note |
|---|---|---|
| Nguyen Duy Anh | duyanh@example.com | Sample user 1 |
| Tran Minh Quan | minhquan@example.com | Sample user 2 |

At the database stage, passwords are stored as placeholder hash strings. For real Flask login, new users should be created through the registration page so the password can be hashed correctly.

---

## 12. Database Design Summary

The database contains seven main tables:

- Users
- Accounts
- ExpenseCategories
- Income
- Expenses
- Budgets
- BalanceHistory

Main relationships:

- Users 1 - N Accounts
- Users 1 - N Income
- Users 1 - N Expenses
- Users 1 - N Budgets
- Accounts 1 - N Income
- Accounts 1 - N Expenses
- Accounts 1 - N BalanceHistory
- ExpenseCategories 1 - N Expenses
- ExpenseCategories 1 - N Budgets

The design separates users, accounts, transactions, categories, budgets, and balance history into different tables. This reduces data redundancy and improves consistency.

---

## 13. Backup and Recovery

### Backup

Run this command in Command Prompt:

```powershell
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqldump.exe" -u root -p personal_finance_db > "D:\Self study\Kì 2 - Năm 2\Database\final\Project\Personal Finance Management\personal_finance_backup.sql"
```

### Restore

Run:

```powershell
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" -u root -p personal_finance_db < "D:\Self study\Kì 2 - Năm 2\Database\final\Project\Personal Finance Management\personal_finance_backup.sql"
```

---

## 14. Current Project Status

### Completed

- Database design
- ERD and relational schema
- MySQL database creation
- Sample data insertion
- Indexes
- Views
- Functions
- Stored procedures
- Triggers
- Backup command
- Basic Flask structure
- Initial register/login page rendering

### In Progress

- Flask authentication
- Dashboard UI
- Account management page
- Income and expense management pages
- Budget management page
- Reports and charts

### Planned Improvements

- Improve web UI design
- Add dashboard cards
- Add expense and income CRUD
- Add charts using Chart.js
- Add budget warning display
- Add better validation and error messages
- Add final report screenshots and demo video

---

## 15. Future Work

Future improvements may include:

- Mobile application version
- Real banking API integration
- Multi-currency support
- Predictive spending analysis
- Email or SMS budget alerts
- AI-based financial advice
- Export reports to PDF or Excel

---

## 16. Conclusion

This project demonstrates how a relational database and a Flask web application can be combined to build a practical personal finance management system. The database supports structured financial data storage, automatic balance tracking, budget monitoring, and financial reporting. The Flask web application provides a user-friendly interface for interacting with the system through a browser.
