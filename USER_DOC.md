# User Documentation

## 1. Services Provided by the Stack
The Inception infrastructure provides a fully containerized, high-availability WordPress environment consisting of three distinct, isolated services:
* **NGINX:** The hardened entrypoint of the infrastructure. It is configured to accept traffic strictly on **Port 443** using the **TLSv1.2 / TLSv1.3** protocol. All insecure Port 80 traffic is disabled.
* **WordPress:** The application engine running on **php-fpm**. It handles the CMS logic and processes dynamic PHP content.
* **MariaDB:** The relational database management system (RDBMS) that stores all site content, user metadata, and configuration settings.

## 2. How to Start and Stop the Project
All commands must be executed from the root of the repository via the terminal.

* **Start the Project:**
	`make`
	Initializes host directories (`/home/eala-lah/data/`), builds custom images from local Dockerfiles, and starts services in the background.

* **Stop the Project (Preserve Data):**
	`make down`
	Stops and removes containers and networks. This preserves all website data and database content stored on the host.

* **Full Reset (Factory Wipe):**
	`make fclean`
	Stops the stack, removes all images, and **permanently deletes** the `/home/eala-lah/data/` folders on the host machine.

## 3. Accessing the Website and Administration Panel

Once the project is running, you can access the interfaces via a web browser:
* **Public Website:** `https://eala-lah.42.fr`
* **Administration Panel:** `https://eala-lah.42.fr/wp-admin`

## 4. Locating and Managing Credentials
Sensitive data is not hardcoded. It is passed securely via files.

* **Locating Credentials:**
	All passwords and usernames are located in the `secrets/` folder at the root of the project:
	* `secrets/db_password.txt` (Database password for the WordPress user)
	* `secrets/db_root_password.txt` (Root password for the MariaDB database)
	* `secrets/credentials.txt` (Password for the WordPress Administrator)
	* `srcs/.env` (Contains non-secret environment variables like the domain name and usernames)

* **Managing Credentials:**
	To change any credentials, you must edit the respective text files in the `secrets/` directory **before** running the project. If the project is already running and you wish to apply new passwords, you must perform a full reset (`make fclean`) to wipe the old database, update the text files, and then rebuild the project (`make`).

## 5. Checking That Services Are Running Correctly

### A. Verify Container Status
Run the following command:
`docker ps`
**Expected Result:** You must see three containers (`nginx`, `wordpress`, `mariadb`). The `STATUS` column must show `Up` and the `PORTS` column for NGINX must show `0.0.0.0:443->443/tcp`.

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
