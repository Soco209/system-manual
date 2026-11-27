# System Installation and Setup Guide

This guide provides technical instructions for configuring, deploying, and verifying the **FSL Learn** application on a local server or development workstation.

The platform employs a hybrid architecture:

- **PHP Web Backend & Assets**: Served via Apache (recommended: Laragon on Windows or XAMPP on macOS) using PDO MySQL.
- **Python Machine Learning Service**: A FastAPI microservice running on Uvicorn that evaluates MediaPipe hand landmark vectors for real-time sign classification.

## System Requirements

Before beginning the installation, verify that the host machine satisfies the following hardware and software requirements:

| Component | Minimum Specification | Recommended Specification |
| :--- | :--- | :--- |
| **Operating System** | Windows 10 (64-bit) or macOS 12+ | Windows 11 (64-bit) or macOS Sonoma |
| **Web Server** | Apache 2.4.x (via Laragon 6.x or XAMPP 8.2+) | Laragon 6.0 Full (Windows) |
| **PHP Runtime** | PHP 8.1.x or 8.2.x (with PDO MySQL, JSON, cURL, OpenSSL) | PHP 8.2+ 64-bit |
| **Python Runtime** | Python 3.10.x to 3.12.x (64-bit) | Python 3.11.9 (64-bit) |
| **Database Server** | MySQL 8.0+ or MariaDB 10.4+ (Default port: 3306) | MySQL 8.0.35+ (`utf8mb4` encoding) |
| **Client Browser** | Google Chrome 110+, Microsoft Edge 110+, or Firefox 115+ | Google Chrome (optimal WebRTC and MediaPipe support) |
| **Camera Hardware** | Integrated 720p webcam or USB web camera | 1080p 30fps webcam for live sign recognition |

!!! warning
    Always ensure database credentials, secret keys, and passwords remain private. Never commit plain-text credentials to public repositories. Back up your `fsl_learn` database regularly before applying migrations or upgrading software packages.

## Step-by-Step Installation Instructions

Follow these numbered steps to configure the web server, database, and Python services.

### Retrieve the Application Codebase

Clone the project repository to your local workspace using Git (https://github.com/your-username/FINAL-FSL.git), or extract the provided capstone release archive:

```powershell
git clone https://github.com/your-username/FINAL-FSL.git
cd FINAL-FSL
```

### Configure the Web Server (Laragon on Windows)

The easiest deployment environment on Windows is **Laragon**:

1. Install and launch **Laragon**.

2. Click **Start All** to activate both **Apache** and **MySQL**.

3. Confirm that Apache is listening on port `80` (or `8080`) and MySQL is listening on port `3306`.

4. Deploy the application files into Laragon's document root directory (`C:\laragon\www\fsl_learn`):

    - Create the directory `C:\laragon\www\fsl_learn` if it does not exist.
    - Copy all files from `backend/php/` directly into `C:\laragon\www\fsl_learn\`.
    - Ensure `.htaccess` is copied to `C:\laragon\www\fsl_learn\.htaccess` to enable API URL rewrites.
    - Copy the `frontend/` directory into `C:\laragon\www\fsl_learn\frontend\`.

Alternatively, if running the Windows deployment helper script, execute `start.bat` in the project root:

```bat
start.bat
```

This automated batch script synchronizes the web assets, verifies the directory structures, opens the default browser, and launches the Python service.

### Set Up and Initialize the MySQL Database

The application connects to a MySQL database named `fsl_learn`.

You can import the schema manually via the MySQL CLI or HeidiSQL (included with Laragon):

```sql
CREATE DATABASE IF NOT EXISTS `fsl_learn` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `fsl_learn`;
SOURCE C:/path/to/FINAL-FSL/database/fslearn_database.sql;
```

Alternatively, the PHP backend contains an automatic bootstrap engine in `backend/php/config.php`. Upon the first API request, the system calls `ensure_database()` to automatically create missing tables, indexes, constraints, seed the 263 lessons, and restore the protected Principal account (`username: principal`).

### Configure Database and Environment Settings

Database credentials and service URLs are defined in `backend/php/config.php`. By default, the system uses standard Laragon local credentials. You can override these using system environment variables or by editing your local configuration:

```ini
# Database Connection Settings
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=your_db_username
DB_PASS=your_db_password_here
DB_NAME=fsl_learn

# Python ML Microservice URL
ML_SERVICE_URL=http://127.0.0.1:8000
```

Sample PHP configuration excerpt from `backend/php/config.php`:

```php
define('DB_HOST', getenv('DB_HOST') ?: '127.0.0.1');
define('DB_PORT', getenv('DB_PORT') ?: '3306');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_NAME', getenv('DB_NAME') ?: 'fsl_learn');
define('ML_SERVICE_URL', getenv('ML_SERVICE_URL') ?: 'http://127.0.0.1:8000');
```

### Set Up the Python Machine Learning Service

The ML service processes hand landmark coordinates sent from the browser client during live sign recognition.

Open a terminal or command prompt, navigate to the `backend/` directory, create a Python virtual environment, and install all required packages:

```powershell
cd backend
python -m venv venv

# On Windows (PowerShell or Command Prompt):
.\venv\Scripts\activate

# On macOS or Linux:
# source venv/bin/activate

python -m pip install --upgrade pip
pip install -r requirements.txt
```

The `requirements.txt` file installs the following packages:

- `fastapi==0.115.0`
- `uvicorn[standard]==0.30.6`
- `python-multipart==0.0.9`
- `pydantic==2.9.2`
- `numpy>=1.26.0,<2.2.0`
- `scikit-learn>=1.3.0,<1.6`
- `joblib>=1.3.0`
- `mediapipe>=0.10.0`
- `opencv-python>=4.8.0`

### Start the Services

Start the Python FastAPI server from the active virtual environment:

```powershell
python run.py
```

The terminal displays startup information confirming Uvicorn is listening:

```text
=======================================================
 FSL Learn — ML Recognition Service
 URL: http://0.0.0.0:8000/api/recognize
 DB API:  served by PHP on Laragon Apache
=======================================================
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

## Verify the Installation

To ensure every component functions correctly, perform the following verification checks:

1. **Verify Python ML Service Health**: Open your terminal and test the health endpoint using curl:

    ```powershell
    curl -i http://127.0.0.1:8000/api/health
    ```

    Confirm that HTTP `200 OK` is returned with `{"status":"ok"}`.

2. **Verify PHP Database Connection**: Navigate to the PHP backend health test URL in your browser:

    ```text
    http://localhost/fsl_learn/health.php
    ```

    The response must return a valid JSON object indicating database connectivity.

3. **Verify Web Frontend Access**: Open Google Chrome and navigate to the application entrance:

    ```text
    http://localhost/fsl_learn/frontend/index.html
    ```

    The landing page should display the logo, navigation links, and the hero section.

Once your installation is verified, proceed to the [User Guide](usage.md) for step-by-step role workflows, or consult the [Troubleshooting Guide](troubleshooting.md) if you encounter any errors.
