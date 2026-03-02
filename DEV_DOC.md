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
* **Permission Enforcement:** Runs `sudo chmod 777` on the host data directories. This ensures the container-specific users (`mysql` and `www-data`) have immediate write access to the volumes.
* **Orchestration:** Launches `docker compose` using **Alpine 3.19** as the base image for all 9 services.
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
1. **Create Data:** Log in to `https://eala-lah.42.fr/wp-admin` and approve a comment.
2. **Hard Reset:** Run `make down` followed by `make`.
3. **Verify:** Access the site; the approved comment must still be visible.

## 5. Bonus Service Verification (CLI)
Use the following commands (or your configured bash aliases) to prove service functionality:

* **Redis Object Cache:** `redis_test`
* **FTP Access:** `ftp_test`
* **Cowsay TCP Service:** `cowsay_test`
* **GoAccess Monitoring:** Verify `report.html` exists in the WordPress volume or access port `7890`.
* **Adminer/Static Site:** `curl -I http://eala-lah.42.fr:8080` and `8081`. 

## 6. System Integrity Checks
* **Alpine Version:** `docker exec wordpress cat /etc/os-release` (Must be 3.19.x).
* **PID 1 Isolation:** `docker exec nginx ps aux` (Master process must be PID 1).
* **Network Isolation:** `docker network inspect inception` (Should show all 9 containers on the same bridge network).
