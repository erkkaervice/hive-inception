NAME			:= inception
DATA_PATH		:= /home/eala-lah/data
SRCDIR			:= srcs
DOCKER_COM		:= $(SRCDIR)/docker-compose.yml

MARIADB_DIR		:= $(DATA_PATH)/mariadb
WORDPRESS_DIR	:= $(DATA_PATH)/wordpress
LOGS_DIR		:= $(DATA_PATH)/logs

# Ensures 'make' runs 'all' by default, even if targets are rearranged later.
.DEFAULT_GOAL	:= all

# The '|' ensures directories exist before starting Docker, but prevents 'Nothing to be done'
all: | $(MARIADB_DIR)
	@docker compose -f $(DOCKER_COM) up --build -d

# Creates host directories and sets permissions before starting Docker.
# docker compose flags:
# -f                : Points Docker to the exact location of the compose file.
# up --build        : Forces fresh image compilation from Dockerfiles before starting.
# -d                : Runs the stack in the background (detached mode).
$(MARIADB_DIR):
	@sudo mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR) $(LOGS_DIR)
	@sudo chmod 777 $(MARIADB_DIR) $(WORDPRESS_DIR) $(LOGS_DIR)

# Gracefully stops containers and the bridge network. Leaves host volumes intact.
down:
	@docker compose -f $(DOCKER_COM) down

# Full Docker wipe.
# down -v           : Deletes internal Docker named volumes in /var/lib/docker/volumes/.
# --rmi all         : Deletes all custom built images for the services.
# --remove-orphans  : Cleans up ghost containers not currently in the compose file.
# || true           : Prevents make from crashing if there is nothing to stop.
# system prune -a   : Removes all unused images (not just dangling ones).
# --force           : Bypasses the terminal Y/N confirmation prompt.
clean:
	@docker compose -f $(DOCKER_COM) down -v --rmi all --remove-orphans || true
	@docker system prune -a --force

# The Nuclear Option: Cleans Docker, then permanently deletes the host data volumes.
fclean: clean
	@sudo rm -rf $(DATA_PATH)

# Full factory reset: wipes everything and rebuilds from scratch.
re: fclean all

# Declares these targets as commands, preventing conflicts with files named "clean", etc.
.PHONY: all down clean fclean re
