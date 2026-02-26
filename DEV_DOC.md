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
* **Host Prep:** Runs `sudo mkdir -p` to create `/home/eala-lah/data/mariadb` and `/home/eala-lah/data/wordpress`.
* **Permission Enforcement:** Runs `sudo chmod 777` on the data directories immediately before launching Docker. This prevents 403 Forbidden and 502 Bad Gateway errors by ensuring the container users (`www-data` and `mysql`) have immediate write access to the host volumes.
* **Build:** Orchestrates `docker compose` using **Alpine 3.19** images.
* **PID 1 Management:** Every Dockerfile ensures the service daemon runs as **PID 1** in the foreground. No "hacky" background scripts (`&`, `tail -f`, `bash`) are used.

## 3. Management Commands
The project is managed entirely through the root `Makefile` to handle container and volume lifecycles safely.

### Makefile Targets:
* `make` (or `make all`): Builds the images and starts the containers in detached mode. Natively prevents relinking if the infrastructure is already running.
* `make down`: Gracefully stops and removes the containers and the default network. Data volumes remain intact.
* `make clean`: Executes `make down` and runs `docker system prune -a --force` to clear unused images and cache.
* `make fclean`: The nuclear option. Tears down containers, removes all images, orphans, and completely deletes the `/home/eala-lah/data` directories from the host machine.
* `make re`: Executes `fclean` followed by `all` for a completely fresh build.

### Docker Management:
* **View running containers:** `docker compose -f srcs/docker-compose.yml ps`
* **Inspect volumes:** `docker volume ls` followed by `docker volume inspect <volume_name>`

## 4. Data Storage & Persistence Verification

The project uses Docker volumes mapped to local host directories to ensure persistence.
* **DB Path:** `/home/eala-lah/data/mariadb`
* **WP Path:** `/home/eala-lah/data/wordpress`

### How to Verify Persistence (Mandatory Defense Step):
1. **Post:** Access `https://eala-lah.42.fr` and post a comment on the "Hello World" post.
2. **Admin Login:** Access `https://eala-lah.42.fr/wp-admin` and log in using the **administrator credentials** found in `secrets/credentials.txt`.
3. **Approve:** Navigate to the **Comments** menu in the sidebar, hover over the pending comment, and click **Approve**. Verify the comment is now visible on the public page.
4. **Crash:** Execute `sudo reboot` on the VM.
5. **Recover:** Once the VM is back, run `make` in the project root. (Note: While Docker may auto-restart containers, this step ensures all host permissions are verified and the stack is fully operational).
6. **Verify:** Refresh the public site; the approved comment must still be visible.

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
