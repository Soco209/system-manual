# Troubleshooting and Diagnostics

This guide provides solutions for common issues encountered when setting up, running, or using the **FSL Learn** platform.

Follow the numbered diagnostic and repair steps in each section to resolve problems quickly.

!!! note

    If you encounter an unexpected error or an issue not covered in this guide, record the exact error text, the browser console output (**F12 > Console**), and the server terminal logs, then contact the development team or your school IT administrator.

## Common Problems and Fixes

### Problem 1: Database Connection Failed (`PDOException [2002]`)

**Symptom**: When loading the website or submitting the login form, the application displays an error: *"Database connection failed"*, *"SQLSTATE[HY000] [2002] Connection refused"*, or an HTTP `500 Internal Server Error`.

**Cause**: The MySQL database service is stopped, running on a non-standard port, or the database credentials in `backend/php/config.php` do not match your MySQL server settings.

**Fix**:

1. Open the **Laragon** control panel (or XAMPP control panel).

2. Check the **MySQL** service indicator. If it is stopped, click **Start All** (or **Start** next to MySQL).

3. Confirm that MySQL is listening on port `3306`. If MySQL is running on another port (such as `3307`), update the port in `backend/php/config.php` or set the environment variable `DB_PORT=3307`.

4. Verify that the database `fsl_learn` exists. Open HeidiSQL or phpMyAdmin, log in with host `127.0.0.1`, user `root`, and empty password (or your configured root password), and verify the database is listed.

5. Check `backend/php/config.php` to ensure the credentials match your server configuration:

```ini

DB_HOST=127.0.0.1

DB_PORT=3306

DB_USER=root

DB_PASS=your_password_here

DB_NAME=fsl_learn

```

6. Refresh the web application in your browser.

---

### Problem 2: Sign Recognition Service Offline (`HTTP 8000 Connection Error`)

**Symptom**: In the Teacher Dashboard under **Sign and Spell** (or student practice), the webcam starts, but hand signs are never recognized or classified. The browser developer console reports: `Failed to load resource: net::ERR_CONNECTION_REFUSED http://127.0.0.1:8000/api/recognize`.

**Cause**: The Python FastAPI ML service (`backend/run.py`) is not running, the Python virtual environment is not activated, or port `8000` is blocked or in use by another program.

**Fix**:

1. Open a new terminal or command prompt window.

2. Navigate to the `backend/` folder of the project:

```bash

cd C:\Users\dexte\Documents\GitHub\FINAL-FSL\backend

```

3. Activate the virtual environment:

```bat

.\venv\Scripts\activate

```

4. Start the machine learning service:

```bash

python run.py

```

5. Test the service health using curl in another terminal:

```bash

curl -i http://127.0.0.1:8000/api/health

```

6. If port `8000` is occupied by another application, identify and terminate the conflicting process:

```bash

netstat -ano | findstr :8000

```

7. Locate the PID from the rightmost column and stop it in Windows Task Manager.

---

### Problem 3: Invalid or Expired Teacher Registration Code

**Symptom**: During teacher registration on `login.html`, the form fails with the error message: *"Invalid Teacher Registration Code. Please check the code and try again."* or *"This Teacher Registration Code has expired. Please request a new code from the Principal."*

**Cause**: The entered code was mistyped, already redeemed by another teacher, or the code's expiration timestamp (`expires_at`) has passed.

**Fix**:

1. Verify that the registration code follows the exact format: `FSL-XXXXXXXX-XXXXXXXX` (16 hexadecimal characters separated by hyphens).

2. Ensure no leading or trailing whitespace was accidentally copied.

3. Have the School Principal log in to `teacher.html` using the principal credentials.

4. In the Principal Dashboard, click **Code Generator** (`data-view="code"`).

5. Review the **Teacher Registration Codes** table:

    - If the code shows `is_used = Yes`, it has already been redeemed.

    - If the code shows `Expired`, its validity window has elapsed.

6. The Principal should generate a fresh code and provide it to the teacher. Refer to the [Code Generator section in the User Guide](usage.md#principal-code-generator).

---

### Problem 4: Learner Enrollment Conflict (`Single Classroom Restriction`)

**Symptom**: When a teacher attempts to add or enroll a student, the system returns an HTTP `409 Conflict` error: *"This learner is already enrolled in classroom 'Grade 1 - Daisy'. Each student can only belong to one classroom at a time."*

**Cause**: The database constraint `uq_student` on table `classroom_members` strictly prevents a student from being registered in more than one classroom concurrently.

**Fix**:

1. Identify the student's current classroom by consulting the previous teacher or asking the Principal to review the **Students Report** (`data-view="report"`).

2. Have the previous teacher open their classroom in `teacher.html`, locate the learner in the roster, and remove the student from that classroom.

3. Once unassigned, the new teacher can immediately enroll the learner using the **Enroll Existing Learner** option.

---

### Problem 5: Webcam Feed Is Black or Camera Access Denied

**Symptom**: When opening **Sign and Spell**, the camera box remains completely black, or a browser pop-up displays `NotAllowedError: Permission denied`.

**Cause**: The browser blocked webcam access, camera permissions were dismissed, or another video conferencing application (Zoom, Microsoft Teams, Google Meet) has locked the webcam hardware.

**Fix**:

1. In Google Chrome or Microsoft Edge, look at the URL address bar. Click the **Camera Settings** icon on the left side of the address bar.

2. Change the camera permission from **Block** to **Allow**.

3. Close any external applications that might be using your webcam (e.g., Zoom, OBS, Teams).

4. Refresh the webpage (`F5` or `Ctrl+F5`).

5. Ensure the room has adequate front-facing lighting so MediaPipe can detect hand landmarks accurately against your background.

---

### Problem 6: API Requests Return HTTP 404 Not Found (`Apache mod_rewrite`)

**Symptom**: Frontend network requests to `/fsl_learn/api/auth/login` or `/fsl_learn/api/classrooms` fail with HTTP `404 Not Found`.

**Cause**: Apache's `mod_rewrite` module is disabled, or the `.htaccess` file was not copied into the web root directory during file deployment.

**Fix**:

1. Verify that the `.htaccess` file exists in `C:\laragon\www\fsl_learn\.htaccess`. If missing, copy it from `backend/php/.htaccess`:

```bat

copy C:\Users\dexte\Documents\GitHub\FINAL-FSL\backend\php\.htaccess C:\laragon\www\fsl_learn\.htaccess

```

2. Ensure `mod_rewrite` is enabled in Apache:

    - In Laragon: Click **Menu > Apache > Modules > rewrite_module** (ensure it has a checkmark).

    - In XAMPP: Open `httpd.conf` and verify `LoadModule rewrite_module modules/mod_rewrite.so` is not commented out.

3. Restart Apache from the Laragon or XAMPP control panel.

## Diagnostic Commands Reference

Use these diagnostic commands in PowerShell or Command Prompt to inspect your runtime environment:

```powershell

# 1. Test MySQL connectivity and verify database tables

mysql -u root -p -e "USE fsl_learn; SHOW TABLES;"

# 2. Check if Apache (port 80) and Python ML (port 8000) are actively listening

Get-NetTCPConnection -LocalPort 80, 8000, 3306 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, State, OwningProcess

# 3. Test the Python FastAPI Health Endpoint directly

Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/health" -Method Get

```

For detailed operational guidance on using each feature, consult the [User Guide](usage.md). For complete installation steps, refer to the [Installation Guide](installation.md).

