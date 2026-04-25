# File: services/account_service.py

# Import hàm kết nối database
from services.db import get_connection


def get_accounts_by_user(user_id):
    """
    Lấy toàn bộ accounts của một user.

    Args:
        user_id (int): ID của user đang đăng nhập

    Returns:
        list[dict]: danh sách accounts của user
    """

    conn = get_connection()

    if conn is None:
        return []

    # dictionary=True để kết quả trả về dạng dict
    # Ví dụ: account["AccountName"], account["Balance"]
    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT AccountID, UserID, AccountName, AccountType, Balance, CreatedAt
            FROM Accounts
            WHERE UserID = %s
            ORDER BY AccountID
        """

        cursor.execute(query, (user_id,))
        accounts = cursor.fetchall()

        return accounts

    finally:
        cursor.close()
        conn.close()


def add_account(user_id, account_name, account_type, balance):
    """
    Thêm account mới cho user.

    Account có thể là:
    - BANK
    - CASH
    - EWALLET

    Args:
        user_id (int): ID của user đang đăng nhập
        account_name (str): tên account
        account_type (str): loại account
        balance (float): số dư ban đầu

    Returns:
        tuple: (success, message)
    """

    # Kiểm tra account type hợp lệ
    valid_types = ["BANK", "CASH", "EWALLET"]

    if account_type not in valid_types:
        return False, "Invalid account type."

    # Kiểm tra balance không âm
    if balance < 0:
        return False, "Initial balance cannot be negative."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor()

    try:
        query = """
            INSERT INTO Accounts (UserID, AccountName, AccountType, Balance)
            VALUES (%s, %s, %s, %s)
        """

        cursor.execute(query, (user_id, account_name, account_type, balance))
        conn.commit()

        return True, "Account added successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to add account: {error}"

    finally:
        cursor.close()
        conn.close()


def delete_account(user_id, account_id):
    """
    Xóa account của user.

    Chỉ cho phép xóa account thuộc về user đang đăng nhập.
    Nếu account đã có income/expense thì database có thể xóa cascade theo thiết kế.

    Args:
        user_id (int): ID user đang đăng nhập
        account_id (int): ID account cần xóa

    Returns:
        tuple: (success, message)
    """

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor()

    try:
        query = """
            DELETE FROM Accounts
            WHERE AccountID = %s AND UserID = %s
        """

        cursor.execute(query, (account_id, user_id))
        conn.commit()

        # rowcount cho biết có dòng nào bị xóa không
        if cursor.rowcount == 0:
            return False, "Account not found or permission denied."

        return True, "Account deleted successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to delete account: {error}"

    finally:
        cursor.close()
        conn.close()