# File: services/budget_service.py

# Import hàm kết nối database
from services.db import get_connection


def get_budgets_by_user(user_id):
    """
    Lấy danh sách budget của user.

    Dữ liệu lấy từ view vw_budget_status,
    vì view này đã tính sẵn:
    - ActualSpent
    - RemainingAmount
    - BudgetStatus

    Args:
        user_id (int): ID user đang login

    Returns:
        list[dict]: danh sách budgets kèm trạng thái
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
            ORDER BY Year DESC, Month DESC, CategoryName
        """

        cursor.execute(query, (user_id,))
        budgets = cursor.fetchall()

        return budgets

    finally:
        cursor.close()
        conn.close()


def get_budget_by_id(user_id, budget_id):
    """
    Lấy một budget theo BudgetID.

    Dùng khi user bấm Edit.
    Hàm này kiểm tra budget có thuộc user đang login không.

    Args:
        user_id (int): ID user đang login
        budget_id (int): ID budget cần lấy

    Returns:
        dict | None: budget record nếu tồn tại và thuộc user
    """

    conn = get_connection()

    if conn is None:
        return None

    cursor = conn.cursor(dictionary=True)

    try:
        query = """
            SELECT
                BudgetID,
                UserID,
                CategoryID,
                Month,
                Year,
                LimitAmount
            FROM Budgets
            WHERE BudgetID = %s
              AND UserID = %s
        """

        cursor.execute(query, (budget_id, user_id))
        budget = cursor.fetchone()

        return budget

    finally:
        cursor.close()
        conn.close()


def add_budget(user_id, category_id, month, year, limit_amount):
    """
    Thêm budget mới.

    Logic:
    1. Kiểm tra month hợp lệ.
    2. Kiểm tra year hợp lệ.
    3. Kiểm tra limit_amount > 0.
    4. Kiểm tra category tồn tại.
    5. Kiểm tra budget cho user-category-month-year đã tồn tại chưa.
    6. Insert budget mới.

    Args:
        user_id (int): ID user đang login
        category_id (int): ID category
        month (int): tháng
        year (int): năm
        limit_amount (float): giới hạn chi tiêu

    Returns:
        tuple: (success, message)
    """

    if month < 1 or month > 12:
        return False, "Month must be between 1 and 12."

    if year < 2000:
        return False, "Year is invalid."

    if limit_amount <= 0:
        return False, "Budget limit must be greater than zero."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor(dictionary=True)

    try:
        # Kiểm tra category có tồn tại không
        cursor.execute(
            """
            SELECT CategoryID
            FROM ExpenseCategories
            WHERE CategoryID = %s
            """,
            (category_id,)
        )

        category = cursor.fetchone()

        if not category:
            return False, "Invalid expense category."

        # Kiểm tra budget đã tồn tại chưa
        cursor.execute(
            """
            SELECT BudgetID
            FROM Budgets
            WHERE UserID = %s
              AND CategoryID = %s
              AND Month = %s
              AND Year = %s
            """,
            (user_id, category_id, month, year)
        )

        existing_budget = cursor.fetchone()

        if existing_budget:
            return False, "Budget for this category and month already exists."

        # Thêm budget mới
        cursor.execute(
            """
            INSERT INTO Budgets (UserID, CategoryID, Month, Year, LimitAmount)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (user_id, category_id, month, year, limit_amount)
        )

        conn.commit()

        return True, "Budget added successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to add budget: {error}"

    finally:
        cursor.close()
        conn.close()


def update_budget(user_id, budget_id, category_id, month, year, limit_amount):
    """
    Cập nhật budget.

    Logic:
    1. Kiểm tra budget thuộc user.
    2. Kiểm tra dữ liệu hợp lệ.
    3. Kiểm tra trùng budget khác.
    4. Update budget.

    Args:
        user_id (int): ID user đang login
        budget_id (int): ID budget cần sửa
        category_id (int): category mới
        month (int): tháng mới
        year (int): năm mới
        limit_amount (float): limit mới

    Returns:
        tuple: (success, message)
    """

    if month < 1 or month > 12:
        return False, "Month must be between 1 and 12."

    if year < 2000:
        return False, "Year is invalid."

    if limit_amount <= 0:
        return False, "Budget limit must be greater than zero."

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor(dictionary=True)

    try:
        # Kiểm tra budget có thuộc user không
        cursor.execute(
            """
            SELECT BudgetID
            FROM Budgets
            WHERE BudgetID = %s
              AND UserID = %s
            """,
            (budget_id, user_id)
        )

        budget = cursor.fetchone()

        if not budget:
            return False, "Budget not found or permission denied."

        # Kiểm tra category tồn tại
        cursor.execute(
            """
            SELECT CategoryID
            FROM ExpenseCategories
            WHERE CategoryID = %s
            """,
            (category_id,)
        )

        category = cursor.fetchone()

        if not category:
            return False, "Invalid expense category."

        # Kiểm tra nếu sửa thành category/month/year đã tồn tại ở budget khác
        cursor.execute(
            """
            SELECT BudgetID
            FROM Budgets
            WHERE UserID = %s
              AND CategoryID = %s
              AND Month = %s
              AND Year = %s
              AND BudgetID <> %s
            """,
            (user_id, category_id, month, year, budget_id)
        )

        duplicate_budget = cursor.fetchone()

        if duplicate_budget:
            return False, "Another budget for this category and month already exists."

        # Update budget
        cursor.execute(
            """
            UPDATE Budgets
            SET CategoryID = %s,
                Month = %s,
                Year = %s,
                LimitAmount = %s
            WHERE BudgetID = %s
              AND UserID = %s
            """,
            (category_id, month, year, limit_amount, budget_id, user_id)
        )

        conn.commit()

        return True, "Budget updated successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to update budget: {error}"

    finally:
        cursor.close()
        conn.close()


def delete_budget(user_id, budget_id):
    """
    Xóa budget.

    Args:
        user_id (int): ID user đang login
        budget_id (int): ID budget cần xóa

    Returns:
        tuple: (success, message)
    """

    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            DELETE FROM Budgets
            WHERE BudgetID = %s
              AND UserID = %s
            """,
            (budget_id, user_id)
        )

        conn.commit()

        if cursor.rowcount == 0:
            return False, "Budget not found or permission denied."

        return True, "Budget deleted successfully."

    except Exception as error:
        conn.rollback()
        return False, f"Failed to delete budget: {error}"

    finally:
        cursor.close()
        conn.close()