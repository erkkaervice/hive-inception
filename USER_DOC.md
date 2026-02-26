# Developer Documentation

## 1. Environment Setup from Scratch
The project requires a Virtual Machine running **Debian** for `ext4` volume permission management.

### Step-by-Step Configuration:
1. **Clone the Repository:** `git clone <repo_url> inception && cd inception`.
2. **Create Secrets Directory:** `mkdir secrets` at the project root.
3. **Populate Secret Files:** Create the following files with **no trailing spaces or newlines**:
	* `secrets/db_password.txt`: Password for the author database user for `wp`.
	* `secrets/db_root_password.txt`: Administrative password for MariaDB `root`.
	* `secrets/credentials.txt`: Administrative password for the WordPress `supervisor`.
4. **Configure Environment:** Edit `srcs/.env` and set `DOMAIN_NAME=eala-lah.42.fr`.

## 2. Infrastructure Build Logic
Running `make` executes a specific build sequence:
* **Host Prep:** Runs `sudo mkdir -p /home/eala-lah/data/mariadb` and `/home/eala-lah/data/wordpress`.
* **Build:** Orchestrates `docker compose` using **Alpine 3.19** images.
* **PID 1 Management:** Every Dockerfile ensures the service daemon runs as **PID 1** in the foreground. No "hacky" background scripts (`&`, `tail -f`, `bash`) are used.

## 3. Data Storage & Persistence Verification
The project uses **Bind Mounts** to map host directories directly into the containers.
* **DB Path:** `/home/eala-lah/data/mariadb`
* **WP Path:** `/home/eala-lah/data/wordpress`

### How to Verify Persistence (Mandatory Defense Step):
1. Access the site and post a new comment on the "Hello World" post.
2. Execute `sudo reboot` on the VM.
3. Once the VM is back, run `make` in the project root.
4. Refresh the browser; the comment must still be visible.

## 4. Technical Verification Commands (Evaluation Checklist)

### Verify Penultimate Alpine Version:
`docker exec wordpress cat /etc/os-release | grep "VERSION_ID"`
**Requirement:** Should return `3.19.x`.

### Verify Database Integrity:
`docker exec -it mariadb mariadb -u root -p$(cat secrets/db_root_password.txt)`
`USE wordpress; SHOW TABLES;`
**Requirement:** Must return 12 tables, proving the volume is correctly mounted and populated.

### Verify Process Isolation (No Hacky Tasks):
`docker exec nginx ps aux`
**Requirement:** PID 1 must be `nginx: master process`. No `bash`, `sh`, or `tail` processes should be running.

### Verify Network Isolation:
`docker network inspect inception`
**Requirement:** Must show all three containers on the same bridge network with no `links` or `host` network enabled.
