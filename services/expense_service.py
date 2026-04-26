# File: services/expense_service.py

# Import hàm kết nối database
from services.db import get_connection


def get_categories():
    """
    Lấy toàn bộ expense categories.

    Dùng để hiển thị dropdown category trong form thêm/sửa expense.

    Returns:
        list[dict]: danh sách categories
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT CategoryID, CategoryName
            FROM ExpenseCategories
            ORDER BY CategoryName
        """

        cursor.execute(query)
        categories = cursor.fetchall()

        return categories

    finally:
        cursor.close()
        conn.close()


def get_expenses_by_user(user_id):
    """
    Lấy toàn bộ expense records của user đang đăng nhập.

    Args:
        user_id (int): ID user trong session

    Returns:
        list[dict]: danh sách expense records
    """

    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        # Join Expenses với Accounts và ExpenseCategories
        # để hiển thị AccountName, AccountType, CategoryName.
        query = """
            SELECT
                e.ExpenseID,
                e.UserID,
                e.AccountID,
                a.AccountName,
                a.AccountType,
                e.CategoryID,
                c.CategoryName,
                e.Amount,
                e.ExpenseDate,
                e.Description,
                e.CreatedAt
            FROM Expenses e
            JOIN Accounts a
                ON e.AccountID = a.AccountID
            JOIN ExpenseCategories c
                ON e.CategoryID = c.CategoryID
            WHERE e.UserID = %s
            ORDER BY e.ExpenseDate DESC, e.ExpenseID DESC
        """

        cursor.execute(query, (user_id,))
        expenses = cursor.fetchall()

        return expenses

    finally:
        cursor.close()
        conn.close()


def get_expense_by_id(user_id, expense_id):
    """
    Lấy một expense record theo ExpenseID.

    Dùng khi user bấm Edit.
    Hàm này cũng kiểm tra expense có thuộc user đang login không.

    Args:
        user_id (int): ID user đang login
        expense_id (int): ID expense cần lấy

    Returns:
        dict | None: expense record nếu tồn tại và thuộc user
    """

    conn = get_connection()

    if conn is None:
        return None

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT
                ExpenseID,
                UserID,
                AccountID,
                CategoryID,
                Amount,
                ExpenseDate,
                Description,
                CreatedAt
            FROM Expenses
            WHERE ExpenseID = %s
              AND UserID = %s
        """

        cursor.execute(query, (expense_id, user_id))
        expense = cursor.fetchone()

        return expense

    finally:
        cursor.close()
        conn.close()


def add_expense(user_id, account_id, category_id, amount, expense_date, description):
    """
    Thêm expense mới.

    Logic:
    1. Kiểm tra amount > 0.
    2. Gọi stored procedure sp_add_expense.
    3. Procedure kiểm tra account thuộc user.
    4. Procedure kiểm tra category tồn tại.
    5. Procedure kiểm tra account đủ balance.
    6. Trigger trg_after_expense_insert tự trừ balance.
    7. Trigger tự ghi BalanceHistory.

    Args:
        user_id (int): user đang đăng nhập
        account_id (int): account dùng để chi
        category_id (int): category của khoản chi
        amount (float): số tiền chi
        expense_date (str): ngày chi
        description (str): mô tả

    Returns:
        tuple: (success, message)
    """

    if amount <= 0:
        return False, "Expense amount must be greater than zero."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor()

    try:
        # Gọi stored procedure đã tạo trong MySQL
        cursor.callproc(
            "sp_add_expense",
            [user_id, account_id, category_id, amount, expense_date, description]
        )

        conn.commit()

        return True, "Expense added successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to add expense: {error}"

    finally:
        cursor.close()
        conn.close()


def update_expense(user_id, expense_id, new_account_id, new_category_id, new_amount, new_expense_date, new_description):
    """
    Cập nhật expense record.

    Vì Expense ảnh hưởng tới Account Balance,
    nên khi sửa expense phải điều chỉnh balance.

    Logic:
    1. Lấy expense cũ.
    2. Kiểm tra expense thuộc user đang login.
    3. Kiểm tra account mới thuộc user.
    4. Kiểm tra category mới tồn tại.
    5. Nếu account không đổi:
        balance = balance - (new_amount - old_amount)
    6. Nếu account đổi:
        old account cộng lại old_amount
        new account trừ new_amount
    7. Update bảng Expenses.
    8. Update BalanceHistory liên quan.

    Args:
        user_id (int): ID user đang login
        expense_id (int): ID expense cần sửa
        new_account_id (int): account mới
        new_category_id (int): category mới
        new_amount (float): amount mới
        new_expense_date (str): ngày chi mới
        new_description (str): mô tả mới

    Returns:
        tuple: (success, message)
    """

    if new_amount <= 0:
        return False, "Expense amount must be greater than zero."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor(dictionary=True)

    try:
        # -------------------------------------------------
        # 1. Lấy expense cũ
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT ExpenseID, UserID, AccountID, CategoryID, Amount
            FROM Expenses
            WHERE ExpenseID = %s
              AND UserID = %s
            """,
            (expense_id, user_id)
        )

        old_expense = cursor.fetchone()

        if not old_expense:
            return False, "Expense record not found or permission denied."

        old_account_id = old_expense["AccountID"]
        old_amount = old_expense["Amount"]

        # -------------------------------------------------
        # 2. Kiểm tra account mới có thuộc user không
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT AccountID, Balance
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
        # 3. Kiểm tra category mới có tồn tại không
        # -------------------------------------------------
        cursor.execute(
            """
            SELECT CategoryID
            FROM ExpenseCategories
            WHERE CategoryID = %s
            """,
            (new_category_id,)
        )

        category = cursor.fetchone()

        if not category:
            return False, "Invalid expense category."

        # -------------------------------------------------
        # 4. Điều chỉnh balance
        # -------------------------------------------------
        if int(old_account_id) == int(new_account_id):
            # Nếu vẫn cùng account:
            # old expense đã trừ old_amount rồi.
            # Khi sửa thành new_amount, chỉ cần trừ thêm phần chênh lệch.
            difference = new_amount - old_amount

            # Nếu difference > 0 nghĩa là chi nhiều hơn trước,
            # cần kiểm tra balance hiện tại có đủ không.
            if difference > 0:
                cursor.execute(
                    """
                    SELECT Balance
                    FROM Accounts
                    WHERE AccountID = %s
                      AND UserID = %s
                    """,
                    (old_account_id, user_id)
                )

                account = cursor.fetchone()

                if account["Balance"] < difference:
                    return False, "Insufficient account balance for this update."

            cursor.execute(
                """
                UPDATE Accounts
                SET Balance = Balance - %s
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (difference, old_account_id, user_id)
            )

        else:
            # Nếu đổi account:
            # account cũ được cộng lại old_amount
            cursor.execute(
                """
                UPDATE Accounts
                SET Balance = Balance + %s
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (old_amount, old_account_id, user_id)
            )

            # Kiểm tra account mới có đủ balance để trừ new_amount không
            cursor.execute(
                """
                SELECT Balance
                FROM Accounts
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (new_account_id, user_id)
            )

            account = cursor.fetchone()

            if account["Balance"] < new_amount:
                return False, "Insufficient account balance for the new account."

            # account mới bị trừ new_amount
            cursor.execute(
                """
                UPDATE Accounts
                SET Balance = Balance - %s
                WHERE AccountID = %s
                  AND UserID = %s
                """,
                (new_amount, new_account_id, user_id)
            )

        # -------------------------------------------------
        # 5. Update bảng Expenses
        # -------------------------------------------------
        cursor.execute(
            """
            UPDATE Expenses
            SET AccountID = %s,
                CategoryID = %s,
                Amount = %s,
                ExpenseDate = %s,
                Description = %s
            WHERE ExpenseID = %s
              AND UserID = %s
            """,
            (
                new_account_id,
                new_category_id,
                new_amount,
                new_expense_date,
                new_description,
                expense_id,
                user_id
            )
        )

        # -------------------------------------------------
        # 6. Update BalanceHistory liên quan
        # ChangeAmount của expense là số âm.
        # ReferenceID của expense chính là ExpenseID.
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
            WHERE ChangeType = 'EXPENSE'
              AND ReferenceID = %s
            """,
            (
                new_account_id,
                -new_amount,
                new_account_id,
                expense_id
            )
        )

        conn.commit()

        return True, "Expense updated successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to update expense: {error}"

    finally:
        cursor.close()
        conn.close()


def delete_expense(user_id, expense_id):
    """
    Xóa một expense record.

    Vì trigger hiện tại chỉ xử lý khi INSERT,
    nên khi DELETE expense, mình phải tự cộng lại balance.

    Logic:
    1. Lấy expense cần xóa.
    2. Kiểm tra expense thuộc user đang login.
    3. Cộng lại amount vào account balance.
    4. Xóa expense.
    5. Xóa balance history liên quan.

    Args:
        user_id (int): user đang đăng nhập
        expense_id (int): expense cần xóa

    Returns:
        tuple: (success, message)
    """

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor(dictionary=True)

    try:
        # Lấy expense cần xóa
        cursor.execute(
            """
            SELECT ExpenseID, UserID, AccountID, Amount
            FROM Expenses
            WHERE ExpenseID = %s
              AND UserID = %s
            """,
            (expense_id, user_id)
        )

        expense = cursor.fetchone()

        if not expense:
            return False, "Expense record not found or permission denied."

        # Cộng lại số tiền expense vào account balance
        cursor.execute(
            """
            UPDATE Accounts
            SET Balance = Balance + %s
            WHERE AccountID = %s
              AND UserID = %s
            """,
            (expense["Amount"], expense["AccountID"], user_id)
        )

        # Xóa expense record
        cursor.execute(
            """
            DELETE FROM Expenses
            WHERE ExpenseID = %s
              AND UserID = %s
            """,
            (expense_id, user_id)
        )

        # Xóa balance history liên quan đến expense này
        cursor.execute(
            """
            DELETE FROM BalanceHistory
            WHERE ChangeType = 'EXPENSE'
              AND ReferenceID = %s
              AND AccountID = %s
            """,
            (expense_id, expense["AccountID"])
        )

        conn.commit()

        return True, "Expense deleted successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to delete expense: {error}"

    finally:
        cursor.close()
        conn.close()