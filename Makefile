LOCAL_BIN := $(shell pwd)/bin
DRAW_MIGRATION_DSN = postgresql://postgres:postgres@localhost:5432/lms?search_path=draw
USER_MIGRATION_DSN = postgresql://postgres:postgres@localhost:5432/lms?search_path=consumer
PAYMENT_MIGRATION_DSN = postgresql://postgres:postgres@localhost:5432/lms?search_path=payment
TICKET_MIGRATION_DSN = postgresql://postgres:postgres@localhost:5432/lms?search_path=ticket

appName = lms
compose = docker compose -f docker-compose.yml -p $(appName)

install-deps:
	GOBIN=$(LOCAL_BIN) go install github.com/pressly/goose/v3/cmd/goose@v3.21.1

db-migrate-draw:
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(DRAW_MIGRATION_DSN) $(LOCAL_BIN)/goose -dir ./draw-service/migrations up

db-migrate-user:
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(USER_MIGRATION_DSN) $(LOCAL_BIN)/goose -dir ./user-service/migrations up

db-migrate-payment:
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(PAYMENT_MIGRATION_DSN) $(LOCAL_BIN)/goose -dir ./payment-service/migrations up

db-migrate-ticket:
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(TICKET_MIGRATION_DSN) $(LOCAL_BIN)/goose -dir ./ticket-service/migrations up


up: install-deps down build
	@echo "Starting app..."
	$(compose) up -d
	@echo "Docker images built and started!"
	make db-migrate-draw
	make db-migrate-user
	make db-migrate-payment
	make db-migrate-ticket
	@echo "DB migrated!"

build:
	@echo "Building images"
	$(compose) build
	@echo "Docker images built!"

down:
	@echo "Stopping docker compose..."
	$(compose) down
	@echo "Done!"

down-v:
	@echo "Stopping docker compose and removing volumes..."
	$(compose) down -v
	@echo "Done!"