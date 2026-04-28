# File: app.py

# Report service: lấy dữ liệu cho reports page và charts
from services.report_service import (
    get_monthly_summary,
    get_category_spending,
    get_account_balance_summary,
    get_transaction_history,
    get_budget_report
)

# Budget service: xử lý xem, thêm, sửa, xóa budgets
from services.budget_service import (
    get_budgets_by_user,
    get_budget_by_id,
    add_budget,
    update_budget,
    delete_budget
)

# Expense service: xử lý xem, thêm, sửa, xóa expenses và lấy categories
from services.expense_service import (
    get_categories,
    get_expenses_by_user,
    get_expense_by_id,
    add_expense,
    update_expense,
    delete_expense
)

# Account service: dùng để lấy danh sách accounts cho form income
from services.account_service import (
    get_accounts_by_user,
    get_account_by_id,
    add_account,
    update_account,
    delete_account
)

# Income service: xử lý xem, thêm, sửa, xóa income
from services.income_service import (
    get_income_by_user,
    get_income_by_id,
    add_income,
    update_income,
    delete_income
)


# datetime dùng để lấy tháng/năm hiện tại
from datetime import datetime

# wraps dùng khi tự viết decorator login_required
from functools import wraps

# Import các thành phần chính của Flask
from flask import Flask, render_template, redirect, url_for, session, request, flash

# SECRET_KEY và session flags dùng cho session/cookie
from config import (
    SECRET_KEY,
    SESSION_COOKIE_SECURE,
    SESSION_COOKIE_HTTPONLY,
    SESSION_COOKIE_SAMESITE
)

# Import các hàm xử lý authentication
from services.auth_service import register_user, authenticate_user

# Import hàm connect database
from services.db import get_connection


# Tạo Flask app
app = Flask(__name__)
app.config.update(
    SESSION_COOKIE_SECURE=SESSION_COOKIE_SECURE,
    SESSION_COOKIE_HTTPONLY=SESSION_COOKIE_HTTPONLY,
    SESSION_COOKIE_SAMESITE=SESSION_COOKIE_SAMESITE,
)

# Secret key dùng để Flask bảo vệ session/cookie
app.secret_key = SECRET_KEY


def login_required(route_function):
    """
    Decorator kiểm tra user đã login chưa.

    Nếu chưa login:
        redirect về trang login

    Nếu đã login:
        cho phép truy cập route
    """

    @wraps(route_function)
    def wrapper(*args, **kwargs):
        # Nếu trong session chưa có user_id nghĩa là chưa login
        if "user_id" not in session:
            flash("Please log in first.")
            return redirect(url_for("login"))

        # Nếu đã login thì chạy route gốc
        return route_function(*args, **kwargs)

    return wrapper


@app.route("/")
def index():
    """
    Route trang chủ.

    Nếu user đã login → chuyển đến dashboard.
    Nếu chưa login → chuyển đến login.
    """

    if "user_id" in session:
        return redirect(url_for("dashboard"))

    return redirect(url_for("login"))


@app.route("/register", methods=["GET", "POST"])
def register():
    """
    Route đăng ký tài khoản.

    GET:
        Hiển thị form register.

    POST:
        Lấy dữ liệu từ form,
        gọi register_user(),
        nếu thành công thì chuyển sang login.
    """

    if request.method == "POST":
        # Lấy dữ liệu từ form register.html
        username = request.form.get("username")
        email = request.form.get("email")
        phone = request.form.get("phone")
        password = request.form.get("password")

        # Gọi service để đăng ký user
        success, message = register_user(username, email, phone, password)

        # flash dùng để hiện thông báo trên giao diện
        flash(message)

        if success:
            return redirect(url_for("login"))

        return redirect(url_for("register"))

    # Nếu là GET request thì chỉ render trang register
    return render_template("register.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    """
    Route đăng nhập.

    GET:
        Hiển thị form login.

    POST:
        Kiểm tra email/password.
        Nếu đúng thì lưu user vào session.
    """

    if request.method == "POST":
        # Lấy email và password từ form login.html
        email = request.form.get("email")
        password = request.form.get("password")

        # Gọi service để xác thực user
        success, user, message = authenticate_user(email, password)

        flash(message)

        if success:
            # Lưu thông tin user vào session
            # session giúp Flask nhớ user đã đăng nhập
            session["user_id"] = user["UserID"]
            session["username"] = user["UserName"]
            session["email"] = user["Email"]

            return redirect(url_for("dashboard"))

        return redirect(url_for("login"))

    # Nếu là GET request thì render trang login
    return render_template("login.html")


@app.route("/logout")
def logout():
    """
    Route đăng xuất.

    Xóa toàn bộ session,
    nghĩa là user không còn trạng thái đăng nhập.
    """

    session.clear()
    flash("Logged out successfully.")
    return redirect(url_for("login"))


@app.route("/dashboard")
@login_required
def dashboard():
    """
    Dashboard sau khi login.

    Trang này lấy dữ liệu thật từ MySQL:
    - Tổng balance
    - Tổng income tháng
    - Tổng expense tháng
    - Net savings
    - Recent transactions
    - Budget alerts
    """

    # Lấy UserID từ session
    user_id = session["user_id"]

    # Lấy tháng/năm hiện tại
    current_date = datetime.now()
    current_month = current_date.month
    current_year = current_date.year

    # Vì sample data của mình đang nằm ở March/April 2026,
    # nên tạm set dashboard mặc định là April 2026 để có dữ liệu hiển thị.
    current_month = 4
    current_year = 2026

    # Kết nối database
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # -------------------------------------------------
        # 1. Lấy tổng số dư tất cả accounts của user
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT COALESCE(SUM(Balance), 0) AS TotalBalance
            FROM Accounts
            WHERE UserID = %s
            """,
            (user_id,)
        )

        balance_result = cursor.fetchone()
        total_balance = balance_result["TotalBalance"]

        # -------------------------------------------------
        # 2. Lấy tổng income, expense, net savings
        # Dùng các SQL functions đã tạo ở file 05_functions.sql
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT 
                fn_total_income(%s, %s, %s) AS TotalIncome,
                fn_total_expense(%s, %s, %s) AS TotalExpense,
                fn_net_savings(%s, %s, %s) AS NetSavings
            """,
            (
                user_id, current_month, current_year,
                user_id, current_month, current_year,
                user_id, current_month, current_year
            )
        )

        summary = cursor.fetchone()

        # -------------------------------------------------
        # 3. Lấy 8 giao dịch gần nhất
        # Dùng view vw_transaction_history đã tạo ở file 04_views.sql
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT *
            FROM vw_transaction_history
            WHERE UserID = %s
            ORDER BY TransactionDate DESC
            LIMIT 8
            """,
            (user_id,)
        )

        recent_transactions = cursor.fetchall()

        # -------------------------------------------------
        # 4. Lấy budget alerts
        # Chỉ lấy những category đang WARNING hoặc OVER_BUDGET
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT *
            FROM vw_budget_status
            WHERE UserID = %s
              AND Month = %s
              AND Year = %s
              AND BudgetStatus IN ('WARNING', 'OVER_BUDGET')
            ORDER BY BudgetStatus DESC, CategoryName
            """,
            (user_id, current_month, current_year)
        )

        budget_alerts = cursor.fetchall()

    finally:
        # Đóng database connection
        cursor.close()
        conn.close()

    # Truyền dữ liệu sang dashboard.html
    return render_template(
        "dashboard.html",
        month=current_month,
        year=current_year,
        total_balance=total_balance,
        total_income=summary["TotalIncome"],
        total_expense=summary["TotalExpense"],
        net_savings=summary["NetSavings"],
        recent_transactions=recent_transactions,
        budget_alerts=budget_alerts
    )

@app.route("/accounts", methods=["GET", "POST"])
@login_required
def accounts():
    """
    Accounts page.

    GET:
        Hiển thị danh sách accounts của user.

    POST:
        Thêm account mới cho user.
    """

    # Lấy user_id từ session
    user_id = session["user_id"]

    if request.method == "POST":
        form_mode = request.form.get("form_mode")
        account_id = request.form.get("account_id")

        # Lấy dữ liệu từ form accounts.html
        account_name = request.form.get("account_name")
        account_type = request.form.get("account_type")
        balance = request.form.get("balance")

        # Chuyển balance từ string sang float
        # Nếu user không nhập thì mặc định là 0
        try:
            balance = float(balance) if balance else 0
        except ValueError:
            flash("Balance must be a number.")
            return redirect(url_for("accounts"))

        if form_mode == "edit":
            try:
                account_id = int(account_id)
            except (TypeError, ValueError):
                flash("Invalid account.")
                return redirect(url_for("accounts"))

            success, message = update_account(
                user_id=user_id,
                account_id=account_id,
                account_name=account_name,
                account_type=account_type,
                balance=balance
            )

            flash(message)
            return redirect(url_for("accounts"))

        # Gọi service để thêm account
        success, message = add_account(
            user_id=user_id,
            account_name=account_name,
            account_type=account_type,
            balance=balance
        )

        flash(message)
        return redirect(url_for("accounts"))

    # Nếu là GET request thì lấy danh sách accounts
    user_accounts = get_accounts_by_user(user_id)
    editing_account = None

    edit_id = request.args.get("edit_id")

    if edit_id:
        try:
            edit_id = int(edit_id)
            editing_account = get_account_by_id(user_id, edit_id)

            if not editing_account:
                flash("Account not found or permission denied.")
                return redirect(url_for("accounts"))

        except ValueError:
            flash("Invalid account.")
            return redirect(url_for("accounts"))

    return render_template(
        "accounts.html",
        accounts=user_accounts,
        editing_account=editing_account
    )

@app.route("/accounts/delete/<int:account_id>", methods=["POST"])
@login_required
def delete_account_route(account_id):
    """
    Xóa account theo account_id.

    Lưu ý:
    Route này dùng POST để tránh việc user vô tình xóa account bằng URL GET.
    """

    user_id = session["user_id"]

    success, message = delete_account(user_id, account_id)

    flash(message)

    return redirect(url_for("accounts"))    

@app.route("/income", methods=["GET", "POST"])
@login_required
def income():
    """
    Income Management page.

    GET:
        - Hiển thị form thêm income.
        - Nếu có query parameter edit_id, form sẽ chuyển sang chế độ edit.
        - Hiển thị danh sách income.

    POST:
        - Nếu form_mode = add: thêm income mới.
        - Nếu form_mode = edit: cập nhật income đang có.
    """

    user_id = session["user_id"]

    # -------------------------------------------------
    # POST request: xử lý Add hoặc Edit income
    # -------------------------------------------------
    if request.method == "POST":
        form_mode = request.form.get("form_mode")
        income_id = request.form.get("income_id")

        account_id = request.form.get("account_id")
        amount = request.form.get("amount")
        income_date = request.form.get("income_date")
        description = request.form.get("description")

        # Kiểm tra amount
        try:
            amount = float(amount)
        except ValueError:
            flash("Income amount must be a number.")
            return redirect(url_for("income"))

        # Kiểm tra account_id
        try:
            account_id = int(account_id)
        except ValueError:
            flash("Invalid account.")
            return redirect(url_for("income"))

        # Nếu form đang ở chế độ edit
        if form_mode == "edit":
            try:
                income_id = int(income_id)
            except ValueError:
                flash("Invalid income record.")
                return redirect(url_for("income"))

            success, message = update_income(
                user_id=user_id,
                income_id=income_id,
                new_account_id=account_id,
                new_amount=amount,
                new_income_date=income_date,
                new_description=description
            )

            flash(message)
            return redirect(url_for("income"))

        # Nếu không phải edit thì mặc định là add
        success, message = add_income(
            user_id=user_id,
            account_id=account_id,
            amount=amount,
            income_date=income_date,
            description=description
        )

        flash(message)
        return redirect(url_for("income"))

    # -------------------------------------------------
    # GET request: hiển thị page
    # -------------------------------------------------

    # Lấy danh sách accounts của user để đổ vào dropdown
    accounts = get_accounts_by_user(user_id)

    # Lấy danh sách income records để hiển thị table
    income_records = get_income_by_user(user_id)

    # Kiểm tra xem user có đang bấm Edit không
    edit_id = request.args.get("edit_id")
    editing_income = None

    if edit_id:
        try:
            edit_id = int(edit_id)
            editing_income = get_income_by_id(user_id, edit_id)

            if not editing_income:
                flash("Income record not found or permission denied.")
                return redirect(url_for("income"))

        except ValueError:
            flash("Invalid income record.")
            return redirect(url_for("income"))

    return render_template(
        "income.html",
        accounts=accounts,
        income_records=income_records,
        editing_income=editing_income
    )


@app.route("/income/delete/<int:income_id>", methods=["POST"])
@login_required
def delete_income_route(income_id):
    """
    Xóa income record.

    Dùng POST để tránh user xóa nhầm bằng URL.
    """

    user_id = session["user_id"]

    success, message = delete_income(user_id, income_id)

    flash(message)

    return redirect(url_for("income"))

@app.route("/expenses", methods=["GET", "POST"])
@login_required
def expenses():
    """
    Expense Management page.

    GET:
        - Hiển thị form thêm expense.
        - Nếu có query parameter edit_id, form chuyển sang chế độ edit.
        - Hiển thị danh sách expense records.

    POST:
        - Nếu form_mode = add: thêm expense mới.
        - Nếu form_mode = edit: cập nhật expense đang có.
    """

    user_id = session["user_id"]

    # -------------------------------------------------
    # POST request: xử lý Add hoặc Edit expense
    # -------------------------------------------------
    if request.method == "POST":
        form_mode = request.form.get("form_mode")
        expense_id = request.form.get("expense_id")

        account_id = request.form.get("account_id")
        category_id = request.form.get("category_id")
        amount = request.form.get("amount")
        expense_date = request.form.get("expense_date")
        description = request.form.get("description")

        # Kiểm tra amount
        try:
            amount = float(amount)
        except ValueError:
            flash("Expense amount must be a number.")
            return redirect(url_for("expenses"))

        # Kiểm tra account_id và category_id
        try:
            account_id = int(account_id)
            category_id = int(category_id)
        except ValueError:
            flash("Invalid account or category.")
            return redirect(url_for("expenses"))

        # Nếu form đang ở chế độ edit
        if form_mode == "edit":
            try:
                expense_id = int(expense_id)
            except ValueError:
                flash("Invalid expense record.")
                return redirect(url_for("expenses"))

            success, message = update_expense(
                user_id=user_id,
                expense_id=expense_id,
                new_account_id=account_id,
                new_category_id=category_id,
                new_amount=amount,
                new_expense_date=expense_date,
                new_description=description
            )

            flash(message)
            return redirect(url_for("expenses"))

        # Nếu không phải edit thì mặc định là add
        success, message = add_expense(
            user_id=user_id,
            account_id=account_id,
            category_id=category_id,
            amount=amount,
            expense_date=expense_date,
            description=description
        )

        flash(message)
        return redirect(url_for("expenses"))

    # -------------------------------------------------
    # GET request: hiển thị page
    # -------------------------------------------------

    # Lấy accounts để đổ vào dropdown account
    accounts = get_accounts_by_user(user_id)

    # Lấy categories để đổ vào dropdown category
    categories = get_categories()

    # Lấy danh sách expense records để hiển thị table
    expense_records = get_expenses_by_user(user_id)

    # Kiểm tra xem user có đang bấm Edit không
    edit_id = request.args.get("edit_id")
    editing_expense = None

    if edit_id:
        try:
            edit_id = int(edit_id)
            editing_expense = get_expense_by_id(user_id, edit_id)

            if not editing_expense:
                flash("Expense record not found or permission denied.")
                return redirect(url_for("expenses"))

        except ValueError:
            flash("Invalid expense record.")
            return redirect(url_for("expenses"))

    return render_template(
        "expenses.html",
        accounts=accounts,
        categories=categories,
        expense_records=expense_records,
        editing_expense=editing_expense
    )


@app.route("/expenses/delete/<int:expense_id>", methods=["POST"])
@login_required
def delete_expense_route(expense_id):
    """
    Xóa expense record.

    Dùng POST để tránh user xóa nhầm bằng URL.
    """

    user_id = session["user_id"]

    success, message = delete_expense(user_id, expense_id)

    flash(message)

    return redirect(url_for("expenses"))

@app.route("/budgets", methods=["GET", "POST"])
@login_required
def budgets():
    """
    Budget Management page.

    GET:
        - Hiển thị form thêm budget.
        - Nếu có query parameter edit_id, form chuyển sang edit mode.
        - Hiển thị danh sách budget status.

    POST:
        - Nếu form_mode = add: thêm budget mới.
        - Nếu form_mode = edit: cập nhật budget đang có.
    """

    user_id = session["user_id"]

    # -------------------------------------------------
    # POST request: xử lý Add hoặc Edit budget
    # -------------------------------------------------
    if request.method == "POST":
        form_mode = request.form.get("form_mode")
        budget_id = request.form.get("budget_id")

        category_id = request.form.get("category_id")
        month = request.form.get("month")
        year = request.form.get("year")
        limit_amount = request.form.get("limit_amount")

        # Ép kiểu dữ liệu
        try:
            category_id = int(category_id)
            month = int(month)
            year = int(year)
            limit_amount = float(limit_amount)
        except ValueError:
            flash("Invalid budget input.")
            return redirect(url_for("budgets"))

        # Nếu form đang ở chế độ edit
        if form_mode == "edit":
            try:
                budget_id = int(budget_id)
            except ValueError:
                flash("Invalid budget record.")
                return redirect(url_for("budgets"))

            success, message = update_budget(
                user_id=user_id,
                budget_id=budget_id,
                category_id=category_id,
                month=month,
                year=year,
                limit_amount=limit_amount
            )

            flash(message)
            return redirect(url_for("budgets"))

        # Nếu không phải edit thì mặc định là add
        success, message = add_budget(
            user_id=user_id,
            category_id=category_id,
            month=month,
            year=year,
            limit_amount=limit_amount
        )

        flash(message)
        return redirect(url_for("budgets"))

    # -------------------------------------------------
    # GET request: hiển thị page
    # -------------------------------------------------

    # Lấy categories cho dropdown
    categories = get_categories()

    # Lấy danh sách budgets kèm status từ view vw_budget_status
    budget_records = get_budgets_by_user(user_id)

    # Kiểm tra user có bấm Edit không
    edit_id = request.args.get("edit_id")
    editing_budget = None

    if edit_id:
        try:
            edit_id = int(edit_id)
            editing_budget = get_budget_by_id(user_id, edit_id)

            if not editing_budget:
                flash("Budget not found or permission denied.")
                return redirect(url_for("budgets"))

        except ValueError:
            flash("Invalid budget record.")
            return redirect(url_for("budgets"))

    return render_template(
        "budgets.html",
        categories=categories,
        budget_records=budget_records,
        editing_budget=editing_budget
    )


@app.route("/budgets/delete/<int:budget_id>", methods=["POST"])
@login_required
def delete_budget_route(budget_id):
    """
    Xóa budget.

    Dùng POST để tránh user xóa nhầm bằng URL.
    """

    user_id = session["user_id"]

    success, message = delete_budget(user_id, budget_id)

    flash(message)

    return redirect(url_for("budgets"))

@app.route("/reports")
@login_required
def reports():
    """
    Reports page.

    Hiển thị:
        - Monthly summary
        - Category-wise spending
        - Budget status
        - Account balance summary
        - Transaction history
        - Chart data
    """

    user_id = session["user_id"]

    # Lấy month/year từ URL.
    # Ví dụ: /reports?month=4&year=2026
    # Nếu không có thì mặc định là 4/2026 vì sample data đang có dữ liệu tháng này.
    try:
        selected_month = int(request.args.get("month", 4))
        selected_year = int(request.args.get("year", 2026))
    except ValueError:
        selected_month = 4
        selected_year = 2026

    # Lấy dữ liệu từ report service
    monthly_summary = get_monthly_summary(user_id)
    category_spending = get_category_spending(user_id, selected_month, selected_year)
    account_balances = get_account_balance_summary(user_id)
    transaction_history = get_transaction_history(user_id, limit=20)
    budget_report = get_budget_report(user_id, selected_month, selected_year)

    # Tìm summary đúng tháng/năm đang chọn
    selected_summary = {
        "TotalIncome": 0,
        "TotalExpense": 0,
        "Savings": 0
    }

    for row in monthly_summary:
        if row["Month"] == selected_month and row["Year"] == selected_year:
            selected_summary = row
            break

    # Data cho chart monthly income vs expense
    monthly_labels = [
        f'{row["Month"]}/{row["Year"]}'
        for row in monthly_summary
    ]

    monthly_income_values = [
        float(row["TotalIncome"] or 0)
        for row in monthly_summary
    ]

    monthly_expense_values = [
        float(row["TotalExpense"] or 0)
        for row in monthly_summary
    ]

    # Data cho chart category spending
    category_labels = [
        row["CategoryName"]
        for row in category_spending
    ]

    category_values = [
        float(row["TotalSpent"] or 0)
        for row in category_spending
    ]

    # Data cho chart budget vs actual
    budget_labels = [
        row["CategoryName"]
        for row in budget_report
    ]

    budget_limit_values = [
        float(row["LimitAmount"] or 0)
        for row in budget_report
    ]

    budget_actual_values = [
        float(row["ActualSpent"] or 0)
        for row in budget_report
    ]

    return render_template(
        "reports.html",

        selected_month=selected_month,
        selected_year=selected_year,

        selected_summary=selected_summary,
        monthly_summary=monthly_summary,
        category_spending=category_spending,
        account_balances=account_balances,
        transaction_history=transaction_history,
        budget_report=budget_report,

        monthly_labels=monthly_labels,
        monthly_income_values=monthly_income_values,
        monthly_expense_values=monthly_expense_values,

        category_labels=category_labels,
        category_values=category_values,

        budget_labels=budget_labels,
        budget_limit_values=budget_limit_values,
        budget_actual_values=budget_actual_values
    )

# Chạy Flask app
if __name__ == "__main__":
    app.run(debug=True)
