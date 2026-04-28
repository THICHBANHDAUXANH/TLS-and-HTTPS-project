# Personal Finance Management with HTTPS/TLS Hardening

This project is a database-driven personal finance web application built with Flask and MySQL. It also demonstrates how to place a local Flask app behind Nginx so the browser accesses it through HTTPS/TLS:

```text
Browser -> https://localhost:443 -> Nginx -> http://127.0.0.1:5000 -> Flask
```

The Flask application handles authentication, accounts, income, expenses, budgets, and reports. Nginx handles HTTPS, HTTP-to-HTTPS redirects, TLS protocol selection, cipher policy, and security headers.

## Features

- User registration and login with hashed passwords.
- Account management for bank, cash, and e-wallet accounts.
- Income and expense tracking.
- Budget planning by category, month, and year.
- Dashboard and report pages backed by SQL views/functions.
- MySQL stored procedures and triggers for financial data processing.
- HTTPS deployment with Nginx reverse proxy.
- TLS hardening and security testing with `curl`, OpenSSL, and Wireshark.

## Tech Stack

| Area | Technology |
| --- | --- |
| Backend | Flask |
| Database | MySQL |
| DB connector | mysql-connector-python |
| Templates | Jinja2 |
| Styling | CSS |
| Password hashing | Werkzeug |
| HTTPS reverse proxy | Nginx |
| Local certificate | mkcert |
| TLS testing | curl, OpenSSL, Wireshark |

## Project Structure

```text
.
├── app.py
├── config.py
├── requirements.txt
├── .env.example
├── database/
│   ├── 00_create_database.sql
│   ├── 01_create_tables.sql
│   ├── 02_insert_sample_data.sql
│   ├── 03_indexes.sql
│   ├── 04_views.sql
│   ├── 05_functions.sql
│   ├── 06_procedures.sql
│   ├── 07_triggers.sql
│   └── 08_backup.sql
├── nginx/
│   └── pfm.conf.example
├── services/
│   ├── db.py
│   ├── auth_service.py
│   ├── account_service.py
│   ├── income_service.py
│   ├── expense_service.py
│   ├── budget_service.py
│   └── report_service.py
├── static/
│   └── style.css
└── templates/
    ├── base.html
    ├── login.html
    ├── register.html
    ├── dashboard.html
    ├── accounts.html
    ├── income.html
    ├── expenses.html
    ├── budgets.html
    └── reports.html
```

## Configuration

Secrets are not stored in `config.py`. The app reads local settings from environment variables and `.env`.

Create your local `.env` file:

```bash
cp .env.example .env
```

Edit `.env`:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=pfm_user
DB_PASSWORD=your-local-password
DB_NAME=personal_finance_db

SECRET_KEY=replace-with-a-long-random-secret

SESSION_COOKIE_SECURE=true
SESSION_COOKIE_HTTPONLY=true
SESSION_COOKIE_SAMESITE=Lax
```

`SESSION_COOKIE_SECURE=true` is correct when you access the app through `https://localhost` via Nginx. If you temporarily test Flask directly at `http://127.0.0.1:5000`, set it to `false` locally so the browser can send the session cookie over HTTP.

## Database Setup

Create the MySQL user yourself, then grant it access to the database. Example:

```sql
CREATE USER 'pfm_user'@'localhost' IDENTIFIED BY 'your-local-password';
GRANT ALL PRIVILEGES ON personal_finance_db.* TO 'pfm_user'@'localhost';
FLUSH PRIVILEGES;
```

Run the SQL scripts in order:

```bash
mysql -u root -p < database/00_create_database.sql
mysql -u root -p personal_finance_db < database/01_create_tables.sql
mysql -u root -p personal_finance_db < database/02_insert_sample_data.sql
mysql -u root -p personal_finance_db < database/03_indexes.sql
mysql -u root -p personal_finance_db < database/04_views.sql
mysql -u root -p personal_finance_db < database/05_functions.sql
mysql -u root -p personal_finance_db < database/06_procedures.sql
mysql -u root -p personal_finance_db < database/07_triggers.sql
```

The sample users use placeholder password hashes, so create a real login account through `/register` when testing the Flask app.

## Run the Flask App

Install dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Test the database connection:

```bash
python3 test_connectdb.py
```

Start Flask:

```bash
python3 app.py
```

By default Flask listens on:

```text
http://127.0.0.1:5000
```

This is the internal backend address. In the HTTPS setup, users should access the app through Nginx at `https://localhost`.

## How the App Works

The application follows a simple server-rendered Flask pattern:

```text
Browser -> app.py route -> services/*.py -> MySQL -> Jinja template -> Browser
```

`app.py` defines routes such as `/login`, `/dashboard`, `/accounts`, `/income`, `/expenses`, `/budgets`, and `/reports`.

The service layer holds database logic:

- `auth_service.py`: register and authenticate users.
- `account_service.py`: create, read, update, and delete accounts.
- `income_service.py`: manage income records.
- `expense_service.py`: manage expense records.
- `budget_service.py`: manage monthly category budgets.
- `report_service.py`: read report views.

The database also contains business logic:

- Stored procedures insert income and expenses.
- Triggers automatically update account balances and write `BalanceHistory`.
- Views prepare transaction history, budget status, monthly summary, and category spending reports.

## HTTPS/TLS Deployment with Nginx

The target deployment model is:

```text
Browser -> https://localhost:443 -> Nginx -> http://127.0.0.1:5000 -> Flask
```

Flask still runs locally on port `5000`. Nginx receives HTTPS traffic on port `443`, terminates TLS, applies hardening headers, and reverse proxies the request into Flask.

### 1. Install Nginx and mkcert

```bash
sudo apt update
sudo apt install nginx libnss3-tools mkcert
```

Check Nginx:

```bash
sudo systemctl status nginx
```

### 2. Create a Local Trusted Certificate

```bash
mkcert -install
mkdir -p ~/certs/pfm
cd ~/certs/pfm
mkcert localhost 127.0.0.1 ::1
```

This creates files similar to:

```text
localhost+2.pem
localhost+2-key.pem
```

The `.pem` file is the certificate. The `-key.pem` file is the private key and must not be committed.

### 3. Install the Nginx Site

Copy the example config:

```bash
sudo cp nginx/pfm.conf.example /etc/nginx/sites-available/pfm
```

Edit the certificate paths:

```bash
sudo nano /etc/nginx/sites-available/pfm
```

Replace `YOUR_USER` with your Linux username:

```nginx
ssl_certificate /home/YOUR_USER/certs/pfm/localhost+2.pem;
ssl_certificate_key /home/YOUR_USER/certs/pfm/localhost+2-key.pem;
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/pfm /etc/nginx/sites-enabled/pfm
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### 4. What the Nginx Config Does

The port 80 block redirects plain HTTP to HTTPS:

```nginx
return 301 https://$host$request_uri;
```

The port 443 block enables HTTPS:

```nginx
listen 443 ssl http2;
ssl_protocols TLSv1.2 TLSv1.3;
```

Only TLS 1.2 and TLS 1.3 are allowed. TLS 1.0, TLS 1.1, and old SSL versions are intentionally disabled.

The reverse proxy rule sends traffic into Flask:

```nginx
location / {
    proxy_pass http://127.0.0.1:5000;
}
```

That line creates the backend half of the flow:

```text
Nginx -> http://127.0.0.1:5000 -> Flask
```

## Security Testing

All HTTPS tests should target `https://localhost`, not `http://127.0.0.1:5000`. Port `5000` bypasses Nginx and therefore bypasses the TLS layer.

### Browser Verification

Open:

```text
https://localhost/login
```

The login page should load over HTTPS.

### HTTP-to-HTTPS Redirect

```bash
curl -I http://localhost/login
```

Expected result:

```text
HTTP/1.1 301 Moved Permanently
Location: https://localhost/login
```

### Security Headers

```bash
curl -I https://localhost/login
```

Expected headers include:

```text
Strict-Transport-Security
X-Frame-Options
X-Content-Type-Options
Referrer-Policy
Content-Security-Policy
```

These mitigate SSL stripping, clickjacking, MIME sniffing, and overly permissive resource loading.

### TLS 1.2 and Cipher Test

```bash
openssl s_client -connect localhost:443 -tls1_2
```

Expected evidence:

```text
Protocol  : TLSv1.2
Cipher    : ECDHE-RSA-AES256-GCM-SHA384
```

`ECDHE` provides Perfect Forward Secrecy, and `AES256-GCM` is a modern authenticated encryption mode.

### TLS 1.0 Rejection

```bash
openssl s_client -connect localhost:443 -tls1
```

Expected result: the handshake fails or no cipher is negotiated. This proves old TLS is disabled.

### Wireshark Verification

Because this project runs on `localhost`, traffic does not leave the machine through Wi-Fi or Ethernet. It travels through the loopback interface:

```text
127.0.0.1 / ::1 / localhost
```

In Wireshark:

1. Start capture on the loopback interface (`lo`, `Loopback`, or `any`).
2. Use the display filter:

```text
tcp.port == 443
```

`443` is the default HTTPS port. The filter shows both directions of the browser-to-Nginx TLS connection.

Open:

```text
https://localhost/login
```

Expected packets:

```text
Client Hello
Server Hello
Application Data
```

`Client Hello` and `Server Hello` prove a TLS handshake occurred. `Application Data` means the HTTP payload is now encrypted inside TLS.

## Risk Reduction

| Threat | Mitigation in this project |
| --- | --- |
| Man-in-the-Middle | HTTPS encrypts browser-to-server traffic. |
| Downgrade attack | Nginx only allows TLS 1.2 and TLS 1.3. |
| SSL stripping | HTTP redirects to HTTPS and HSTS is enabled. |
| Clickjacking | `X-Frame-Options: DENY` and CSP `frame-ancestors 'none'`. |
| MIME sniffing | `X-Content-Type-Options: nosniff`. |
| Cookie theft via JavaScript | Flask session cookie uses `HttpOnly`. |
| Session over HTTP | Flask session cookie uses `Secure` when HTTPS is enabled. |

