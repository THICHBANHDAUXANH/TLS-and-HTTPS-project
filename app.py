# File: app.py

# Import account service để xử lý accounts
from services.account_service import get_accounts_by_user, add_account, delete_account

# datetime dùng để lấy tháng/năm hiện tại
from datetime import datetime

# wraps dùng khi tự viết decorator login_required
from functools import wraps

# Import các thành phần chính của Flask
from flask import Flask, render_template, redirect, url_for, session, request, flash

# SECRET_KEY dùng cho session
from config import SECRET_KEY

# Import các hàm xử lý authentication
from services.auth_service import register_user, authenticate_user

# Import hàm connect database
from services.db import get_connection


# Tạo Flask app
app = Flask(__name__)

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

    return render_template(
        "accounts.html",
        accounts=user_accounts
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

# Chạy Flask app
if __name__ == "__main__":
    app.run(debug=True)