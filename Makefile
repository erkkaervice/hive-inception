NAME		:= inception
DATA_PATH	:= /home/eala-lah/data
SRCDIR		:= srcs
DOCKER_COM	:= $(SRCDIR)/docker-compose.yml

MARIADB_DIR	:= $(DATA_PATH)/mariadb
WORDPRESS_DIR	:= $(DATA_PATH)/wordpress

.DEFAULT_GOAL := all

all: $(MARIADB_DIR)

$(MARIADB_DIR):
	@sudo mkdir -p $(MARIADB_DIR) $(WORDPRESS_DIR)
	@sudo chmod 777 $(MARIADB_DIR) $(WORDPRESS_DIR)
	@docker compose -f $(DOCKER_COM) up --build -d

down:
	@docker compose -f $(DOCKER_COM) down

clean:
	@docker compose -f $(DOCKER_COM) down -v --rmi all --remove-orphans || true
	@docker system prune -a --force

fclean: clean
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all down clean fclean re
