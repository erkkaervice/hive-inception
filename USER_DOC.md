# User Documentation

## 1. Services Provided by the Stack
The Inception infrastructure provides a fully containerized, high-availability environment consisting of 9 distinct, isolated services:
* **NGINX:** The hardened entrypoint of the infrastructure. It is configured to accept traffic strictly on **Port 443** using the **TLSv1.2 / TLSv1.3** protocol. All insecure Port 80 traffic is disabled.
* **WordPress:** The application engine running on **php-fpm82**. It handles the CMS logic and processes dynamic PHP content.
* **MariaDB:** The relational database management system (RDBMS) that stores all site content, user metadata, and configuration settings.
* **Redis:** An in-memory data structure store used as an object cache to drastically reduce WordPress database query times.
* **FTP Server:** Allows secure file transfer and management directly to the WordPress volume.
* **Adminer:** A lightweight, single-file database management web UI.
* **Static Website:** A secondary web service serving static HTML content via a Python HTTP server.
* **GoAccess:** A real-time web log analyzer providing a visual dashboard of NGINX traffic via WebSockets.
* **Cowsay:** A bonus TCP service running via socat.

## 2. How to Start and Stop the Project
All commands must be executed from the root of the repository via the terminal.

* **Start the Project:**
	`make`
	Automatically generates secure passwords, initializes host directories (`/home/eala-lah/data/`), builds custom images from local Dockerfiles, and starts all 9 services in the background.

* **Stop the Project (Preserve Data):**
	`make down`
	Stops and removes containers and networks. This preserves all website data and database content stored on the host.

* **Full Reset (Factory Wipe):**
	`make fclean`
	Stops the stack, removes all images, and **permanently deletes** the `/home/eala-lah/data/` folders and the `secrets/` directory on the host machine.

## 3. Accessing the Services
Once the project is running, you can access the interfaces via a web browser or client:
* **Public WordPress Website:** `https://eala-lah.42.fr`
* **WordPress Administration Panel:** `https://eala-lah.42.fr/wp-admin`
* **Adminer Database Manager:** `http://eala-lah.42.fr:8080`
* **Static Website:** `http://eala-lah.42.fr:8081`
* **GoAccess Live Logs:** `http://eala-lah.42.fr:7890`
* **FTP Server:** Port 21 (connect via FileZilla or terminal).
* **Cowsay Service:** Port 4243.



## 4. Locating and Managing Passwords
Sensitive data is not hardcoded. The `Makefile` automatically generates them on the first run.

* **Locating Passwords:**
	All passwords and usernames are located in the `secrets/` folder at the root of the project:
	* `db_user_password.txt` (Database password for the WordPress user)
	* `db_root_password.txt` (Root password for the MariaDB database)
	* `wp_admin_password.txt` (Password for the WordPress Administrator)
	* `wp_user_password.txt` (Password for the regular WordPress User)
	* `ftp_password.txt` (Password for the FTP User)
	* `srcs/.env` (Contains non-secret environment variables like the domain name and usernames)

* **Managing Passwords:**
	To change any password, you must edit the respective text files in the `secrets/` directory **before** running the project. If the project is already running and you wish to apply new passwords, you must perform a full reset (`make fclean`) to wipe the old database, update the text files, and then rebuild the project (`make`).

## 5. Checking That Services Are Running Correctly

### A. Verify Container Status
Run the following command:
	`docker ps`
**Expected Result:** You must see 9 containers (`nginx`, `wordpress`, `mariadb`, `redis`, `ftp`, `adminer`, `static_site`, `goaccess`, `cowsay`). The `STATUS` column must show `Up`.

### B. Verify SSL/TLS Security (Port 443 & TLS)
1. **Check for TLS Protocol:**
	`curl -I -v --tls-max 1.3 --tlsv1.3 https://eala-lah.42.fr 2>&1 | grep "SSL connection using"`
	**Requirement:** Output must state `SSL connection using TLSv1.3` (or TLSv1.2).
2. **Verify Port 80 is Closed:**
	`curl -I http://eala-lah.42.fr`
	**Requirement:** Must result in `Connection refused`.
3. **Verify Domain Resolution:**
	`ping eala-lah.42.fr`
	**Requirement:** Must resolve to `127.0.0.1`.
