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


def get_account_by_id(user_id, account_id):
    """
    Lay mot account theo AccountID.

    Ham nay dung khi user bam Edit va cung kiem tra account co thuoc
    user dang login khong.
    """

    conn = get_connection()

    if conn is None:
        return None

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT AccountID, UserID, AccountName, AccountType, Balance, CreatedAt
            FROM Accounts
            WHERE AccountID = %s
              AND UserID = %s
        """

        cursor.execute(query, (account_id, user_id))
        account = cursor.fetchone()

        return account

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


def update_account(user_id, account_id, account_name, account_type, balance):
    """
    Cap nhat thong tin account cua user dang login.
    """

    valid_types = ["BANK", "CASH", "EWALLET"]

    if not account_name or not account_name.strip():
        return False, "Account name is required."

    if account_type not in valid_types:
        return False, "Invalid account type."

    if balance < 0:
        return False, "Balance cannot be negative."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor()

    try:
        query = """
            UPDATE Accounts
            SET AccountName = %s,
                AccountType = %s,
                Balance = %s
            WHERE AccountID = %s
              AND UserID = %s
        """

        cursor.execute(
            query,
            (account_name.strip(), account_type, balance, account_id, user_id)
        )
        conn.commit()

        if cursor.rowcount == 0:
            cursor.execute(
                """
                SELECT AccountID
                FROM Accounts
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (account_id, user_id)
            )

            if not cursor.fetchone():
                return False, "Account not found or permission denied."

        return True, "Account updated successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to update account: {error}"

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
