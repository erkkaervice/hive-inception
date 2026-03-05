# User Documentation

## 1. Services Provided by the Stack
The Inception infrastructure provides a fully containerized environment consisting of 9 distinct, isolated services:
* **NGINX:** The hardened entrypoint. Configured for **Port 443** using **TLSv1.2 / TLSv1.3**. Port 80 traffic is strictly disabled.
* **WordPress:** Application engine running on **php-fpm82**.
* **MariaDB:** Relational database storing all CMS content and metadata.
* **Redis:** In-memory data store used as an object cache for WordPress.
* **FTP Server:** Provides secure access to the WordPress volume for file management.
* **Adminer:** Lightweight web UI for database management.
* **Static Website:** Secondary non-PHP web service.
* **GoAccess:** Real-time log analyzer providing traffic dashboards.
* **Cowsay:** Bonus TCP service demonstrating raw socket communication via `socat`.

## 2. How to Start and Stop the Project
All commands must be executed from the root of the repository. **Pre-requisite:** Ensure your `.env` file and `secrets/` directory are populated.

* **Start the Project:**
    `make`
    Initializes host directories (`/home/eala-lah/data/`), builds custom images, and launches the 9-service stack.

* **Stop the Project (Preserve Data):**
    `make down`
    Stops and removes containers and networks while preserving all data on the host volumes.

* **Full Reset (Factory Wipe):**
    `make fclean`
    Stops the stack, removes all images, and **permanently deletes** the `/home/eala-lah/data/` volumes and the `secrets/` directory.

## 3. Accessing the Services
Verify connectivity via browser or CLI:
* **Public WordPress Website:** `https://eala-lah.42.fr`
* **WordPress Administration Panel:** `https://eala-lah.42.fr/wp-admin`
* **Adminer Database Manager:** `http://eala-lah.42.fr:8080`
* **Static Website:** `http://eala-lah.42.fr:8081`
* **GoAccess Live Logs:** `http://eala-lah.42.fr:7890`
* **FTP Server:** Port 21 (Use credentials from `secrets/ftp_password.txt`).
* **Cowsay Service:** Port 4243 (Use `nc localhost 4243`).

## 4. Locating and Managing Passwords
Sensitive data is handled via Docker Secrets and environment variables. These must be defined prior to the build.

* **Locating Passwords:**
    Credentials are stored in the `secrets/` folder at the root of the project:
    * `db_user_password.txt` (Database password for the WordPress user)
    * `db_root_password.txt` (Root password for MariaDB)
    * `wp_admin_password.txt` (Password for the WordPress Administrator)
    * `wp_user_password.txt` (Password for the regular WordPress User)
    * `ftp_password.txt` (Password for the FTP User)
    * `srcs/.env` (Contains non-secret variables like domain name and usernames)

## 5. Checking That Services Are Running Correctly

### A. Verify Container Status
Run the following command:
`docker ps`
**Expected Result:** 9 containers must be listed as `Up`.

### B. Verify SSL/TLS Security
1. **Check for TLS Protocol:**
    `docker exec nginx cat /etc/nginx/http.d/default.conf | grep ssl_protocols`
    `echo | openssl s_client -connect localhost:443 2>/dev/null | grep "Protocol"`
    **Requirement:** Must show `TLSv1.3` (or TLSv1.2).
2. **Verify Port 80 is Closed:**
    `curl -I http://eala-lah.42.fr`
    **Requirement:** Must result in `Connection refused`.
3. **Verify Domain Resolution:**
    `ping eala-lah.42.fr`
    **Requirement:** Must resolve to `127.0.0.1`.

### C. Database Integrity Check
To verify that the database is correctly initialized and contains WordPress data:
1. **Login to MariaDB Container:**
   `docker exec -it mariadb mariadb -u root -p$(cat secrets/db_root_password.txt)`
2. **Verify Data:**
   - List databases: `SHOW DATABASES;`
   - Select your database: `USE inception_db;` (or the name in your .env)
   - List tables: `SHOW TABLES;`
3. **Requirement:** You must see tables such as `wp_users`, `wp_posts`, and `wp_comments`. This proves the database is not empty and is synced with WordPress.
