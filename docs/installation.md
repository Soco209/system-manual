\# System Installation and Setup Guide



This guide provides technical instructions for configuring, deploying, and verifying the \*\*FSL Learn\*\* application on a local server or development workstation.



The platform employs a hybrid architecture:



\- \*\*PHP Web Backend \& Assets\*\*: Served via Apache (recommended: Laragon on Windows or XAMPP on macOS) using PDO MySQL.

\- \*\*Python Machine Learning Service\*\*: A FastAPI microservice running on Uvicorn that evaluates MediaPipe hand landmark vectors for real-time sign classification.



\## System Requirements



Before beginning the installation, verify that the host machine satisfies the following hardware and software requirements:



| Component | Minimum Specification | Recommended Specification |

| :--- | :--- | :--- |

| \*\*Operating System\*\* | Windows 10 (64-bit) or macOS 12+ | Windows 11 (64-bit) or macOS Sonoma |

| \*\*Web Server\*\* | Apache 2.4.x (via Laragon 6.x or XAMPP 8.2+) | Laragon 6.0 Full (Windows) |

| \*\*PHP Runtime\*\* | PHP 8.1.x or 8.2.x (with PDO MySQL, JSON, cURL, OpenSSL) | PHP 8.2+ 64-bit |

| \*\*Python Runtime\*\* | Python 3.10.x to 3.12.x (64-bit) | Python 3.11.9 (64-bit) |

| \*\*Database Server\*\* | MySQL 8.0+ or MariaDB 10.4+ (Default port: 3306) | MySQL 8.0.35+ (`utf8mb4` encoding) |

| \*\*Client Browser\*\* | Google Chrome 110+, Microsoft Edge 110+, or Firefox 115+ | Google Chrome (optimal WebRTC and MediaPipe support) |

| \*\*Camera Hardware\*\* | Integrated 720p webcam or USB web camera | 1080p 30fps webcam for live sign recognition |



!!! warning

&#x20;   Always ensure database credentials, secret keys, and passwords remain private. Never commit plain-text credentials to public repositories. Back up your `fsl\_learn` database regularly before applying migrations or upgrading software packages.



\## Step-by-Step Installation Instructions



Follow these numbered steps to configure the web server, database, and Python services.



\### 1. Retrieve the Application Codebase



Clone the project repository to your local workspace using Git \[TODO: confirm repository URL], or extract the provided capstone release archive:



```bash

git clone https://github.com/your\_organization/FINAL-FSL.git

cd FINAL-FSL

```



\### 2. Configure the Web Server (Laragon on Windows)



The easiest deployment environment on Windows is \*\*Laragon\*\*:



1\. Install and launch \*\*Laragon\*\*.

2\. Click \*\*Start All\*\* to activate both \*\*Apache\*\* and \*\*MySQL\*\*.

3\. Confirm that Apache is listening on port `80` (or `8080`) and MySQL is listening on port `3306`.

4\. Deploy the application files into Laragon's document root directory (`C:\\laragon\\www\\fsl\_learn`):

&#x20;   - Create the directory `C:\\laragon\\www\\fsl\_learn` if it does not exist.

&#x20;   - Copy all files from `backend/php/` directly into `C:\\laragon\\www\\fsl\_learn\\`.

&#x20;   - Ensure `.htaccess` is copied to `C:\\laragon\\www\\fsl\_learn\\.htaccess` to enable API URL rewrites.

&#x20;   - Copy the `frontend/` directory into `C:\\laragon\\www\\fsl\_learn\\frontend\\`.



Alternatively, if running the Windows deployment helper script, execute `start.bat` in the project root:



```bat

start.bat

```



This automated batch script synchronizes the web assets, verifies the directory structures, opens the default browser, and launches the Python service.



\### 3. Set Up and Initialize the MySQL Database



The application connects to a MySQL database named `fsl\_learn`.



You can import the schema manually via the MySQL CLI or HeidiSQL (included with Laragon):



```sql

CREATE DATABASE IF NOT EXISTS `fsl\_learn` CHARACTER SET utf8mb4 COLLATE utf8mb4\_unicode\_ci;

USE `fsl\_learn`;

SOURCE C:/Users/dexte/Documents/GitHub/FINAL-FSL/database/fslearn\_database.sql;

```



Alternatively, the PHP backend contains an automatic bootstrap engine in `backend/php/config.php`. Upon the first API request, the system calls `ensure\_database()` to automatically create missing tables, indexes, constraints, seed the 263 lessons, and restore the protected Principal account (`username: principal`).



\### 4. Configure Database and Environment Settings



Database credentials and service URLs are defined in `backend/php/config.php`. By default, the system uses standard Laragon local credentials. You can override these using system environment variables or by editing your local configuration:



```ini

\# Database Connection Settings

DB\_HOST=127.0.0.1

DB\_PORT=3306

DB\_USER=your\_db\_username

DB\_PASS=your\_db\_password\_here

DB\_NAME=fsl\_learn



\# Python ML Microservice URL

ML\_SERVICE\_URL=http://127.0.0.1:8000

```



Sample PHP configuration excerpt from `backend/php/config.php`:



```php

define('DB\_HOST', getenv('DB\_HOST') ?: '127.0.0.1');

define('DB\_PORT', getenv('DB\_PORT') ?: '3306');

define('DB\_USER', getenv('DB\_USER') ?: 'root');

define('DB\_PASS', getenv('DB\_PASS') ?: '');

define('DB\_NAME', getenv('DB\_NAME') ?: 'fsl\_learn');



define('ML\_SERVICE\_URL', getenv('ML\_SERVICE\_URL') ?: 'http://127.0.0.1:8000');

```



\### 5. Set Up the Python Machine Learning Service



The ML service processes hand landmark coordinates sent from the browser client during live sign recognition.



Open a terminal or command prompt, navigate to the `backend/` directory, create a Python virtual environment, and install all required packages:



```bash

cd backend

python -m venv venv



\# On Windows (PowerShell or Command Prompt):

.\\venv\\Scripts\\activate



\# On macOS or Linux:

\# source venv/bin/activate



python -m pip install --upgrade pip

pip install -r requirements.txt

```



The `requirements.txt` file installs the following packages:



\- `fastapi==0.115.0`

\- `uvicorn\[standard]==0.30.6`

\- `python-multipart==0.0.9`

\- `pydantic==2.9.2`

\- `numpy>=1.26.0,<2.2.0`

\- `scikit-learn>=1.3.0,<1.6`

\- `joblib>=1.3.0`

\- `mediapipe>=0.10.0`

\- `opencv-python>=4.8.0`



\### 6. Start the Services



Start the Python FastAPI server from the active virtual environment:



```bash

python run.py

```



The terminal displays startup information confirming Uvicorn is listening:



```

=======================================================

&#x20;FSL Learn — ML Recognition Service

&#x20;URL: http://0.0.0.0:8000/api/recognize

&#x20;DB API:  served by PHP on Laragon Apache

=======================================================

INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)

```



\## Verify the Installation



To ensure every component functions correctly, perform the following verification checks:



1\. \*\*Verify Python ML Service Health\*\*: Open your terminal and test the health endpoint using curl:



```bash

curl -i http://127.0.0.1:8000/api/health

```



Confirm that HTTP `200 OK` is returned with `{"status":"ok"}`.



2\. \*\*Verify PHP Database Connection\*\*: Navigate to the PHP backend health test URL in your browser:



```text

http://localhost/fsl\_learn/health.php

```



The response must return a valid JSON object indicating database connectivity.



3\. \*\*Verify Web Frontend Access\*\*: Open Google Chrome and navigate to the application entrance:



```text

http://localhost/fsl\_learn/frontend/index.html

```



The landing page should display the logo, navigation links, and the hero section.



Once your installation is verified, proceed to the \[User Guide](usage.md) for step-by-step role workflows, or consult the \[Troubleshooting Guide](troubleshooting.md) if you encounter any errors.



