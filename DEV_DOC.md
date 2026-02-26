# User Documentation

## 1. Provided Services
The Inception infrastructure provides a fully containerized, high-availability WordPress environment consisting of three distinct, isolated services:
* **NGINX:** The hardened entrypoint of the infrastructure. It is configured to accept traffic strictly on **Port 443** using the **TLSv1.3** protocol. All insecure Port 80 traffic is disabled.
* **WordPress:** The application engine running on **php-fpm82**. It handles the CMS logic and processes dynamic PHP content.
* **MariaDB:** The relational database management system (RDBMS) that stores all site content, user metadata, and configuration settings.

## 2. Operational Commands (Start and Stop)
All commands must be executed from the root of the repository:
* **Launch Site:** `make`
	- Initializes host directories (`/home/eala-lah/data/`).
	- Builds custom images from local Dockerfiles.
	- Starts services in detached mode.
* **Stop Site (Persistence Mode):** `make down`
	- Stops and removes containers and networks.
	- **Note:** This preserves all website data and database content stored on the host for reboot tests.
* **Full Reset:** `make fclean`
	- Stops the stack, removes all images, and **permanently deletes** the `/home/eala-lah/data/` folders on the host machine. Use this to return the project to a "factory" state.

## 3. Accessing the Site
* **Public Website:** `https://eala-lah.42.fr`
* **WordPress Admin Dashboard:** `https://eala-lah.42.fr/wp-admin`
* **Administrator Account:** `supervisor` (Password in `secrets/credentials.txt`).
* **Regular Author Account:** `author` (Password in `secrets/db_password.txt`).

## 4. Troubleshooting & Manual Verification
### A. Verify Services are Running
Run the following command:
`docker ps`
**Expected Result:** You must see three containers (`nginx`, `wordpress`, `mariadb`). The `STATUS` column must show `Up` and the `PORTS` column for NGINX must show `0.0.0.0:443->443/tcp`.

### B. Verify SSL/TLS Security (Port 443 & TLSv1.3)
1. **Check for TLSv1.3 Protocol:**
	`curl -I -v --tls-max 1.3 --tlsv1.3 https://eala-lah.42.fr 2>&1 | grep "SSL connection using"`
	**Requirement:** Output must state `SSL connection using TLSv1.3`.
2. **Verify Port 80 is Closed:**
	`curl -I http://eala-lah.42.fr`
	**Requirement:** Must result in `Connection refused`.
3. **Verify Domain:**
	`ping eala-lah.42.fr`
	**Requirement:** Must resolve to `127.0.0.1`.

### C. Locate Credentials
Sensitive data is stored in the `secrets/` folder at the root:
* `secrets/db_password.txt`
* `secrets/db_root_password.txt`
* `secrets/credentials.txt`
