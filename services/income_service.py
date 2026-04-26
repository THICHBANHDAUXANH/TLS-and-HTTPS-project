# File: services/income_service.py

# Import hàm kết nối database
from services.db import get_connection


def get_income_by_user(user_id):
    """
    Lấy toàn bộ income records của user đang đăng nhập.

    Args:
        user_id (int): ID của user trong session

    Returns:
        list[dict]: danh sách income records
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT
                i.IncomeID,
                i.UserID,
                i.AccountID,
                a.AccountName,
                a.AccountType,
                i.Amount,
                i.IncomeDate,
                i.Description,
                i.CreatedAt
            FROM Income i
            JOIN Accounts a
                ON i.AccountID = a.AccountID
            WHERE i.UserID = %s
            ORDER BY i.IncomeDate DESC, i.IncomeID DESC
        """

        cursor.execute(query, (user_id,))
        income_records = cursor.fetchall()

        return income_records

    finally:
        cursor.close()
        conn.close()


def get_income_by_id(user_id, income_id):
    """
    Lấy một income record theo IncomeID.

    Dùng khi user bấm Edit.
    Hàm này cũng kiểm tra income đó có thuộc user đang login không.

    Args:
        user_id (int): ID user đang login
        income_id (int): ID income cần lấy

    Returns:
        dict | None: income record nếu tồn tại và thuộc user
    """

    conn = get_connection()

    if conn is None:
        return None

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT
                IncomeID,
                UserID,
                AccountID,
                Amount,
                IncomeDate,
                Description,
                CreatedAt
            FROM Income
            WHERE IncomeID = %s
              AND UserID = %s
        """

        cursor.execute(query, (income_id, user_id))
        income = cursor.fetchone()

        return income

    finally:
        cursor.close()
        conn.close()


def add_income(user_id, account_id, amount, income_date, description):
    """
    Thêm income mới.

    Logic:
    1. Kiểm tra amount > 0.
    2. Gọi stored procedure sp_add_income.
    3. sp_add_income insert record vào bảng Income.
    4. Trigger trg_after_income_insert tự cộng Balance.
    5. Trigger cũng tự ghi BalanceHistory.

    Args:
        user_id (int): user đang đăng nhập
        account_id (int): account nhận tiền
        amount (float): số tiền income
        income_date (str): ngày nhận tiền
        description (str): mô tả

    Returns:
        tuple: (success, message)
    """

    if amount <= 0:
        return False, "Income amount must be greater than zero."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor()

    try:
        # Gọi stored procedure đã tạo trong MySQL
        cursor.callproc(
            "sp_add_income",
            [user_id, account_id, amount, income_date, description]
        )

        conn.commit()

        return True, "Income added successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to add income: {error}"

    finally:
        cursor.close()
        conn.close()


def update_income(user_id, income_id, new_account_id, new_amount, new_income_date, new_description):
    """
    Cập nhật income record.

    Vì Income ảnh hưởng tới Account Balance,
    nên khi sửa income phải điều chỉnh balance.

    Logic:
    1. Lấy income cũ.
    2. Kiểm tra income thuộc user đang login.
    3. Nếu account không đổi:
        balance = balance + (new_amount - old_amount)
    4. Nếu account đổi:
        old account trừ lại old_amount
        new account cộng new_amount
    5. Update bảng Income.
    6. Update BalanceHistory liên quan.

    Args:
        user_id (int): ID user đang login
        income_id (int): ID income cần sửa
        new_account_id (int): account mới
        new_amount (float): amount mới
        new_income_date (str): ngày income mới
        new_description (str): mô tả mới

    Returns:
        tuple: (success, message)
    """

    if new_amount <= 0:
        return False, "Income amount must be greater than zero."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor(dictionary=True)

    try:
        # -------------------------------------------------
        # 1. Lấy income cũ
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT IncomeID, UserID, AccountID, Amount
            FROM Income
            WHERE IncomeID = %s
              AND UserID = %s
            """,
            (income_id, user_id)
        )

        old_income = cursor.fetchone()

        if not old_income:
            return False, "Income record not found or permission denied."

        old_account_id = old_income["AccountID"]
        old_amount = old_income["Amount"]

        # -------------------------------------------------
        # 2. Kiểm tra account mới có thuộc user không
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT AccountID
            FROM Accounts
            WHERE AccountID = %s
              AND UserID = %s
            """,
            (new_account_id, user_id)
        )

        new_account = cursor.fetchone()

        if not new_account:
            return False, "Invalid account for this user."

        # -------------------------------------------------
        # 3. Điều chỉnh balance
        # -------------------------------------------------
        if int(old_account_id) == int(new_account_id):
            # Nếu vẫn cùng account, chỉ cộng/trừ phần chênh lệch
            difference = new_amount - old_amount

            cursor.execute(
                """
                UPDATE Accounts
                SET Balance = Balance + %s
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (difference, old_account_id, user_id)
            )

        else:
            # Nếu đổi account:
            # account cũ bị trừ lại old_amount
            cursor.execute(
                """
                UPDATE Accounts
                SET Balance = Balance - %s
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (old_amount, old_account_id, user_id)
            )

            # account mới được cộng new_amount
            cursor.execute(
                """
                UPDATE Accounts
                SET Balance = Balance + %s
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (new_amount, new_account_id, user_id)
            )

        # -------------------------------------------------
        # 4. Update bảng Income
        # -------------------------------------------------
        cursor.execute(
            """
            UPDATE Income
            SET AccountID = %s,
                Amount = %s,
                IncomeDate = %s,
                Description = %s
            WHERE IncomeID = %s
              AND UserID = %s
            """,
            (
                new_account_id,
                new_amount,
                new_income_date,
                new_description,
                income_id,
                user_id
            )
        )

        # -------------------------------------------------
        # 5. Update BalanceHistory liên quan
        # ReferenceID của income chính là IncomeID
        # -------------------------------------------------
        cursor.execute(
            """
            UPDATE BalanceHistory
            SET AccountID = %s,
                ChangeAmount = %s,
                BalanceAfter = (
                    SELECT Balance
                    FROM Accounts
                    WHERE AccountID = %s
                ),
                ChangeDate = NOW()
            WHERE ChangeType = 'INCOME'
              AND ReferenceID = %s
            """,
            (
                new_account_id,
                new_amount,
                new_account_id,
                income_id
            )
        )

        conn.commit()

        return True, "Income updated successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to update income: {error}"

    finally:
        cursor.close()
        conn.close()


def delete_income(user_id, income_id):
    """
    Xóa một income record.

    Lưu ý:
    Trigger của mình hiện chỉ xử lý khi INSERT.
    Vì vậy khi DELETE income, mình phải tự trừ lại balance.

    Logic:
    1. Lấy income cần xóa.
    2. Kiểm tra income có thuộc user đang login không.
    3. Trừ lại amount khỏi account balance.
    4. Xóa income.
    5. Xóa balance history liên quan.

    Args:
        user_id (int): user đang đăng nhập
        income_id (int): income cần xóa

    Returns:
        tuple: (success, message)
    """

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor(dictionary=True)

    try:
        # Lấy income cần xóa
        cursor.execute(
            """
            SELECT IncomeID, UserID, AccountID, Amount
            FROM Income
            WHERE IncomeID = %s
              AND UserID = %s
            """,
            (income_id, user_id)
        )

        income = cursor.fetchone()

        if not income:
            return False, "Income record not found or permission denied."

        # Trừ lại số tiền income khỏi account balance
        cursor.execute(
            """
            UPDATE Accounts
            SET Balance = Balance - %s
            WHERE AccountID = %s
              AND UserID = %s
            """,
            (income["Amount"], income["AccountID"], user_id)
        )

        # Xóa income record
        cursor.execute(
            """
            DELETE FROM Income
            WHERE IncomeID = %s
              AND UserID = %s
            """,
            (income_id, user_id)
        )

        # Xóa balance history liên quan đến income này
        cursor.execute(
            """
            DELETE FROM BalanceHistory
            WHERE ChangeType = 'INCOME'
              AND ReferenceID = %s
              AND AccountID = %s
            """,
            (income_id, income["AccountID"])
        )

        conn.commit()

        return True, "Income deleted successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to delete income: {error}"

    finally:
        cursor.close()
        conn.close()