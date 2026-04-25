personal-finance-system/
├── app.py
├── config.py
├── requirements.txt
├── database/
│   ├── 00_create_database.sql
│   ├── 01_create_tables.sql
│   ├── 02_insert_sample_data.sql
│   ├── 03_indexes.sql
│   ├── 04_views.sql
│   ├── 05_functions.sql
│   ├── 06_procedures.sql
│   └── 07_triggers.sql
├── templates/
│   ├── login.html
│   ├── register.html
│   ├── dashboard.html
│   ├── accounts.html
│   ├── income.html
│   ├── expenses.html
│   ├── budgets.html
│   └── reports.html
├── static/
│   └── style.css
└── services/
    ├── db.py
    ├── auth_service.py
    ├── account_service.py
    ├── income_service.py
    ├── expense_service.py
    ├── budget_service.py
    └── report_service.py