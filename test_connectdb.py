# File: test_connectdb.py

from services.db import get_connection


def main():
    connection = get_connection()

    if connection is None:
        print("Database connection failed.")
        return

    print("Database connection successful.")
    connection.close()


if __name__ == "__main__":
    main()
