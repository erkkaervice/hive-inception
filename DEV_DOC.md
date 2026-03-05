# Developer Documentation

## 1. Environment Setup from Scratch
The project requires a Virtual Machine running **Debian** for `ext4` volume permission management.

### Step-by-Step Configuration:
1. **Clone the Repository:** `git clone <repo_url> <name> && cd <name>`.
2. **Secrets Setup:** Manually create a `secrets/` directory at the root of the project.
3. **Manual Password Provisioning:** Create the following files in the `secrets/` directory. Each file must contain **only the password string** with no trailing newlines, spaces, or usernames:
    * `db_user_password.txt`: Password for the database user.
    * `db_root_password.txt`: Administrative password for MariaDB root.
    * `wp_admin_password.txt`: Password for the WordPress administrator.
    * `wp_user_password.txt`: Password for the regular WordPress user.
    * `ftp_password.txt`: Password for the FTP user.
4. **Configure Environment:** Edit `srcs/.env` to define your usernames (`MYSQL_USER`, `FTP_USER`, etc.) and your `DOMAIN_NAME`. The containers will map these usernames to the passwords stored in the `secrets/` files.

## 2. Infrastructure Build Logic
Running `make` executes a strict, reproducible build sequence:
* **Host Prep:** Runs `sudo mkdir -p` to create `/home/eala-lah/data/mariadb` and `/home/eala-lah/data/wordpress`.
* **Permission Enforcement:** Runs `sudo chmod 777` on the host data directories. This ensures the container-specific users have immediate write access to the volumes.
* **Orchestration:** Launches `docker compose` using **Alpine 3.22** as the base image for all 9 services.
* **PID 1 Management:** Every Dockerfile is written to ensure the service daemon runs as **PID 1**. This ensures proper signal handling and avoids "zombie" processes.

## 3. Management Commands
The project lifecycle is managed via the `Makefile` to handle host-level dependencies alongside the containers.

### Makefile Targets:
* `make`: Builds images and starts the 9-container stack.
* `make down`: Stops containers and removes the bridge network. **Volumes are preserved.**
* `make clean`: Removes containers, networks, and all project-specific images.
* `make fclean`: The "Nuclear Option." Performs a full clean and **permanently deletes** the `/home/eala-lah/data` directories and the `secrets/` folder.
* `make re`: Triggers a full `fclean` followed by a fresh `make`.

## 4. Data Storage & Persistence Verification
The project maps container internal paths to host directories for persistence:
* **Database:** `/home/eala-lah/data/mariadb` ↔ `/var/lib/mysql`
* **WordPress:** `/home/eala-lah/data/wordpress` ↔ `/var/www/html`

### How to Verify Core Persistence:
1. **Create Data:** Log in to `https://eala-lah.42.fr/wp-admin` and post a comment.
2. **Database Verification (Internal):** Log in to the database (see USER_DOC for command) and run:
   `SELECT comment_content FROM wp_comments;` 
   Confirm your comment is stored in the MariaDB container.
3. **Hard Reset:** Run `make down` followed by `make`.
4. **Final Check:** Re-run the SQL command. The comment must still exist, proving the data survived the container destruction because it is stored on the host at `/home/eala-lah/data/mariadb`.

## 5. Bonus Service Verification (CLI & Browser)
Use the following methods to prove service functionality and inter-service connectivity:

* **Redis Object Cache:**
    - **Utility:** Reduces database load and increases site speed by storing frequently accessed data (queries/objects) in RAM rather than re-fetching from MariaDB.
    - **CLI Proof:** `docker exec redis redis-cli ping` (Expect: `PONG`)
    - **Network Proof:** `docker exec wordpress nc -zv redis 6379` (Expect: `open`)
    - **Application Proof:** Login to `https://eala-lah.42.fr/wp-admin`, go to Redis Object Cache settings, and verify the status is **"Connected"**.

* **FTP Access:**
    - **Utility:** Provides a standardized way for administrators to upload, download, and manage website files (themes, plugins, media) without needing direct SSH access to the host.
    - **Command:** `curl -v --ftp-ssl --insecure ftp://localhost:21 --user $(grep FTP_USER srcs/.env | cut -d '=' -f2):$(cat secrets/ftp_password.txt)`
    - **Expect:** `230 Login successful`. Note: `curl` may require `--insecure` or `--ssl` flags if TLS is enforced.
    - **GUI Proof:** Open **FileZilla**, connect to `localhost:21`. 
    - **Note:** If TLS is not enabled, accept the "Insecure connection" warning. If TLS is enabled, verify the certificate matches your NGINX self-signed cert.

* **Cowsay TCP Service:**
    - **Utility:** Demonstrates the ability to handle raw TCP traffic through a "socket" relay (socat), showing how simple microservices can communicate outside of standard HTTP/HTTPS protocols.
    - **Command:** `echo "Inception Proof" | nc localhost 4243`
    - **Expect:** An ASCII cow appearing in the terminal. This proves the `socat` raw TCP socket is listening and processing data.

* **GoAccess Monitoring:**
    - **Utility:** Transforms raw NGINX access logs into a visual, real-time dashboard. This allows administrators to monitor traffic spikes, security threats (404/403 errors), and visitor demographics instantly.
    - **Command:** `docker exec goaccess ls -l /var/www/html/report.html`
    - **Expect:** File details with a recent timestamp. This proves GoAccess is successfully parsing NGINX logs and writing the report to the shared volume.
    - **Browser Proof:** Go to `http://eala-lah.42.fr:7890` (or your proxied route) to see the live traffic dashboard.

* **Adminer/Static Site:**
    - **Utility (Adminer):** A lightweight database management tool that replaces heavy alternatives like phpMyAdmin. It allows for direct SQL execution and database maintenance via a web browser.
    - **Utility (Static Site):** Provides a high-performance, low-resource way to serve fixed content (like a resume or documentation) without needing the overhead of a PHP engine or Database.
    - **Command:** `curl -I http://localhost:8080` and `curl -I http://localhost:8081`
    - **Expect:** `HTTP/1.1 200 OK`. This proves the secondary web servers are up and serving requests.
    - **Browser Proof (Adminer):** Visit `http://eala-lah.42.fr:8080` to log in and manage the database.
    - **Browser Proof (Static):** Visit `http://eala-lah.42.fr:8081` to view the non-PHP static website.

## 6. System Integrity Checks
* **Alpine Version:** `docker exec wordpress cat /etc/os-release` (Must be 3.22.x).
* **PID 1 Isolation:** `docker exec nginx ps aux` (Master process must be PID 1).
* **Network Isolation:** `docker network inspect inception` (Should show all 9 containers on the same bridge network).

## 7. Container Lifecycle (PID 1)
To ensure system integrity and pass strict evaluation checks, no background loops (e.g., `tail -f`, `sleep infinity`) are used in this stack. 
* **Direct Daemons:** Services like NGINX and Redis are configured to run directly in the foreground.
* **Setup Scripts:** For services requiring initialization (MariaDB, WordPress, FTP), the startup shell scripts terminate with the `exec` command (e.g., `exec php-fpm82 -F`). This destroys the shell process and replaces it with the service daemon, promoting it to **PID 1**. This ensures Docker accurately tracks the service health and can send graceful shutdown signals (`SIGTERM`) directly to the application.
