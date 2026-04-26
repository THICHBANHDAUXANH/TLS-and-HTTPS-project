# File: services/report_service.py

# Import hàm kết nối database
from services.db import get_connection


def get_monthly_summary(user_id):
    """
    Lấy báo cáo tổng hợp tài chính theo tháng của user.

    Dữ liệu lấy từ view:
        vw_monthly_financial_summary

    View này đã tính sẵn:
        - TotalIncome
        - TotalExpense
        - Savings

    Args:
        user_id (int): ID của user đang đăng nhập

    Returns:
        list[dict]: danh sách summary theo từng tháng
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT
                UserID,
                UserName,
                Year,
                Month,
                TotalIncome,
                TotalExpense,
                Savings
            FROM vw_monthly_financial_summary
            WHERE UserID = %s
            ORDER BY Year ASC, Month ASC
        """

        cursor.execute(query, (user_id,))
        monthly_summary = cursor.fetchall()

        return monthly_summary

    finally:
        cursor.close()
        conn.close()


def get_category_spending(user_id, month, year):
    """
    Lấy báo cáo chi tiêu theo category trong một tháng/năm cụ thể.

    Dữ liệu lấy từ view:
        vw_category_wise_spending

    View này đã group expense theo:
        - UserID
        - Month
        - Year
        - CategoryID
        - CategoryName

    Args:
        user_id (int): ID user đang đăng nhập
        month (int): tháng cần xem
        year (int): năm cần xem

    Returns:
        list[dict]: danh sách chi tiêu theo category
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
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
            WHERE UserID = %s
              AND Month = %s
              AND Year = %s
            ORDER BY TotalSpent DESC
        """

        cursor.execute(query, (user_id, month, year))
        category_spending = cursor.fetchall()

        return category_spending

    finally:
        cursor.close()
        conn.close()


def get_account_balance_summary(user_id):
    """
    Lấy danh sách account và balance hiện tại của user.

    Dữ liệu lấy từ view:
        vw_account_balance_summary

    Args:
        user_id (int): ID user đang đăng nhập

    Returns:
        list[dict]: danh sách accounts kèm balance
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT
                AccountID,
                UserID,
                UserName,
                AccountName,
                AccountType,
                Balance,
                CreatedAt
            FROM vw_account_balance_summary
            WHERE UserID = %s
            ORDER BY AccountID ASC
        """

        cursor.execute(query, (user_id,))
        account_balances = cursor.fetchall()

        return account_balances

    finally:
        cursor.close()
        conn.close()


def get_transaction_history(user_id, limit=20):
    """
    Lấy lịch sử giao dịch gồm cả income và expense.

    Dữ liệu lấy từ view:
        vw_transaction_history

    View này gộp Income và Expenses thành một bảng transaction chung.

    Args:
        user_id (int): ID user đang đăng nhập
        limit (int): số lượng transaction muốn lấy

    Returns:
        list[dict]: danh sách giao dịch gần đây
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
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
            WHERE UserID = %s
            ORDER BY TransactionDate DESC, TransactionID DESC
            LIMIT %s
        """

        cursor.execute(query, (user_id, limit))
        transactions = cursor.fetchall()

        return transactions

    finally:
        cursor.close()
        conn.close()


def get_budget_report(user_id, month, year):
    """
    Lấy budget report của user trong một tháng/năm cụ thể.

    Dữ liệu lấy từ view:
        vw_budget_status

    View này đã tính sẵn:
        - LimitAmount
        - ActualSpent
        - RemainingAmount
        - BudgetStatus

    Args:
        user_id (int): ID user đang đăng nhập
        month (int): tháng cần xem
        year (int): năm cần xem

    Returns:
        list[dict]: danh sách budget status
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
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
            WHERE UserID = %s
              AND Month = %s
              AND Year = %s
            ORDER BY CategoryName ASC
        """

        cursor.execute(query, (user_id, month, year))
        budget_report = cursor.fetchall()

        return budget_report

    finally:
        cursor.close()
        conn.close()