NAME = inception
COMPOSE = docker-compose -f srcs/docker-compose.yml

all: up

up:
@echo "Starting $(NAME)..."
@$(COMPOSE) up -d --build

down:
@echo "Stopping $(NAME)..."
@$(COMPOSE) down

clean:
@echo "Removing containers, images, and volumes..."
@$(COMPOSE) down -v --rmi all --remove-orphans
@docker system prune -af --volumes

re: down clean up

logs:
@$(COMPOSE) logs -f

ps:
@$(COMPOSE) ps

.PHONY: all up down clean re logs ps