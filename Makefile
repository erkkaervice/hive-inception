NAME	=	inception

all:
	@printf "Launching configuration ${NAME}...\n"
	@sudo mkdir -p /home/eala-lah/data/mariadb
	@sudo mkdir -p /home/eala-lah/data/wordpress
	@docker compose -f srcs/docker-compose.yml up --build -d

help:
	@printf "Available targets:\n"
	@printf "  all     - Build and run the stack\n"
	@printf "  down    - Stop and remove containers\n"
	@printf "  re      - Full rebuild\n"
	@printf "  clean   - Remove containers and unused images\n"
	@printf "  fclean  - Remove everything including data volumes\n"

down:
	@printf "Stopping configuration ${NAME}...\n"
	@docker compose -f srcs/docker-compose.yml down

re: fclean all

clean: down
	@printf "Cleaning unused images and cache...\n"
	@docker system prune -a --force

fclean:
	@printf "Total cleanup of ${NAME}...\n"
	@docker compose -f srcs/docker-compose.yml down -v --rmi all
	@sudo rm -rf /home/eala-lah/data/mariadb
	@sudo rm -rf /home/eala-lah/data/wordpress
	@printf "Data folders and images removed.\n"

.PHONY: all down re clean fclean help
