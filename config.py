import os

from dotenv import load_dotenv


load_dotenv()


def _get_bool(name, default=False):
    value = os.getenv(name)

    if value is None:
        return default

    return value.strip().lower() in {"1", "true", "yes", "on"}


DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "pfm_user"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "personal_finance_db"),
}

SECRET_KEY = os.getenv("SECRET_KEY", "change-this-secret-key")

SESSION_COOKIE_SECURE = _get_bool("SESSION_COOKIE_SECURE", True)
SESSION_COOKIE_HTTPONLY = _get_bool("SESSION_COOKIE_HTTPONLY", True)
SESSION_COOKIE_SAMESITE = os.getenv("SESSION_COOKIE_SAMESITE", "Lax")
