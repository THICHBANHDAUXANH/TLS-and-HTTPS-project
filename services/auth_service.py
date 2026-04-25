# File: services/auth_service.py

# generate_password_hash: biến password thật thành password hash để lưu vào database
# check_password_hash: kiểm tra password user nhập có khớp với hash trong database không
from werkzeug.security import generate_password_hash, check_password_hash

# Import hàm kết nối database
from services.db import get_connection


def get_user_by_email(email):
    """
    Tìm user theo email.

    Vì email là unique trong bảng Users,
    nên hàm này trả về tối đa 1 user.

    Args:
        email (str): email user nhập

    Returns:
        dict: thông tin user nếu tìm thấy
        None: nếu không tìm thấy user
    """

    # Tạo kết nối database
    conn = get_connection()

    # Nếu kết nối thất bại thì trả về None
    if conn is None:
        return None

    # dictionary=True giúp kết quả trả về dạng dict
    # Ví dụ: user["Email"], user["PasswordHash"]
    cursor = conn.cursor(dictionary=True)

    try:
        # Query tìm user theo email
        query = """
            SELECT UserID, UserName, Email, PhoneNumber, PasswordHash
            FROM Users
            WHERE Email = %s
        """

        # Dùng %s để tránh SQL injection
        cursor.execute(query, (email,))

        # fetchone() lấy 1 dòng kết quả
        user = cursor.fetchone()

        return user

    finally:
        # Luôn đóng cursor và connection sau khi dùng xong
        cursor.close()
        conn.close()


def register_user(username, email, phone, password):
    """
    Đăng ký user mới.

    Các bước:
    1. Kiểm tra email đã tồn tại chưa
    2. Hash password
    3. Insert user vào bảng Users

    Args:
        username (str): tên user
        email (str): email
        phone (str): số điện thoại
        password (str): password thật user nhập

    Returns:
        tuple: (success, message)
    """

    # Kiểm tra xem email đã có trong database chưa
    existing_user = get_user_by_email(email)

    if existing_user:
        return False, "Email already exists."

    # Hash password trước khi lưu vào database
    # Không bao giờ lưu password thật vào database
    password_hash = generate_password_hash(password)

    # Tạo kết nối database
    conn = get_connection()

    if conn is None:
        return False, "Database connection failed."

    cursor = conn.cursor()

    try:
        # Insert user mới vào bảng Users
        query = """
            INSERT INTO Users (UserName, Email, PhoneNumber, PasswordHash)
            VALUES (%s, %s, %s, %s)
        """

        cursor.execute(query, (username, email, phone, password_hash))

        # commit để lưu thay đổi vào database
        conn.commit()

        return True, "Registration successful. Please log in."

    except Exception as error:
        # Nếu insert lỗi thì rollback để hủy thay đổi
        conn.rollback()
        return False, f"Registration failed: {error}"

    finally:
        cursor.close()
        conn.close()


def authenticate_user(email, password):
    """
    Xác thực login.

    Các bước:
    1. Tìm user theo email
    2. Nếu không có user → login fail
    3. Nếu có user → kiểm tra password nhập vào với PasswordHash
    4. Nếu đúng → login success

    Args:
        email (str): email user nhập
        password (str): password user nhập

    Returns:
        tuple: (success, user, message)
    """

    # Tìm user trong database
    user = get_user_by_email(email)

    if not user:
        return False, None, "Invalid email or password."

    # So sánh password user nhập với PasswordHash trong database
    if not check_password_hash(user["PasswordHash"], password):
        return False, None, "Invalid email or password."

    # Nếu đúng thì trả về user
    return True, user, "Login successful."