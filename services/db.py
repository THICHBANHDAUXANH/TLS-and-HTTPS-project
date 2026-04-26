# File: services/db.py

import mysql.connector
from config import DB_CONFIG


def get_connection():
    """
    Create and return a MySQL database connection.
    """
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except mysql.connector.Error as error:
        print(f"Database connection error: {error}")
        return None
