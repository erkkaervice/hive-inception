# Inception

*This project has been created as part of the 42 curriculum by [eala-lah].*

## About the Author
* **Intra Login:** `eala-lah`
* **Network:** 42 Network
* **Role:** System Administrator and Developer

## Description
This project aims to broaden system administration knowledge by using Docker to virtualize a specific web infrastructure. The goal is to set up a robust, multi-container infrastructure composed of NGINX (TLS v1.3), WordPress + php-fpm, MariaDB, and a suite of 6 bonus services (Redis, FTP, Adminer, Static Site, GoAccess, Cowsay) under strict rules, running within a dedicated Debian virtual machine.

This project utilizes Docker to containerize and isolate every component. Each service runs in its own dedicated container with no "hacky" background processes. 
- **NGINX:** Only entrypoint (Port 443).
- **WordPress:** Handles PHP processing via php-fpm82.
- **MariaDB:** Isolated database backend.
- **Bonus Services:** Enhance observability, performance, and management.

## Instructions
The entire application is automated via a `Makefile` at the root of the directory.
1. **Prerequisites:** A Debian Virtual Machine with Docker and Docker Compose (V2) installed.
2. **Execution:** Run `make` at the root directory. The Makefile will automatically generate the required passwords in a `secrets/` folder, initialize the host volumes at `/home/eala-lah/data/`, build the custom Alpine-based images, and launch the stack.
3. **Shutdown:** Run `make down` to stop the services or `make fclean` to wipe all data, secrets, and images.

## Resources
* **Docker Official Documentation:** Used for understanding Containerization and Docker Compose Specification.
* **NGINX Documentation:** Used for configuring strictly TLSv1.2 and TLSv1.3 protocols and SSL ciphers.
* **AI Usage:** AI was utilized to troubleshoot filesystem permission conflicts encountered when mapping volumes to external drives, refactor the infrastructure to satisfy Linux UID/GID requirements, integrate Redis object caching natively into the WP-CLI build sequence, and standardize the Makefile logic for complex 9-container orchestration.

## Architectural Comparisons

### Virtual Machines vs Docker
* **Virtual Machines:** Emulate hardware and require a full Guest OS (heavy).
* **Docker:** Virtualizes the OS kernel. Containers share the host kernel, making them lightweight, portable, and significantly faster.

### Secrets vs Environment Variables
* **Secrets:** Injected into containers via `/run/secrets/` using memory-only mounts (`tmpfs`). They never persist on the container's read-write layer.
* **Environment Variables:** Used for non-sensitive data (e.g., `DOMAIN_NAME`). They are less secure for passwords as they can be easily inspected via `docker inspect` or environment dumps.

### Docker Network vs Host Network
* **Docker Network:** An isolated bridge network where containers communicate via internal DNS (service names). This setup strictly avoids the forbidden `network: host` and `links:` flags.
* **Host Network:** Removes isolation by mapping container ports directly to the host's stack, creating security risks and port conflicts.

### Docker Volumes vs Bind Mounts
* **Docker Volumes:** Managed by Docker in a dedicated area of the filesystem.
* **Bind Mounts:** Maps a specific host path (`/home/eala-lah/data/`) to the container. This project utilizes bind mounts to ensure data persistence on the host's `ext4` filesystem as required by the subject.
