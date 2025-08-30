# Variables
DOCKER ?= podman
COMPOSE := $(DOCKER)-compose -f ./compose.yaml
PROJECT_DIR := .
IMAGE_NAME := podman-repro

## Application configuration

# Note that this port is external from the view of the container
# It may still be an internal port for the TLS proxy
EXTERNAL_PORT ?= 29913

# The real public URL people can see, for e.g. RSS feed links
APP_PUBLIC_URL ?= https://app.example.com
APP_REPOSITORY_URL ?= https://github.com/fry69/fresh-vite-podman-repro
NODE_ENV ?= production

# Semi-random value for DENO_DEPLOYMENT_ID, to enable proper client caching
# see -> https://fresh.deno.dev/docs/concepts/deployment#-docker
GIT_REVISION=$(shell git rev-parse HEAD)

# Build version including timestamp
APP_BUILD_STRING := App $(shell date '+%Y%m%d-%H%M%S') (git $(shell git rev-parse --short HEAD))

# Export variables for docker-compose
export IMAGE_NAME
export PROJECT_DIR
export EXTERNAL_PORT
export GIT_REVISION
export APP_PUBLIC_URL
export APP_REPOSITORY_URL
export NODE_ENV
export APP_BUILD_STRING

# Default target
all: help

# Show available targets
help:
	@echo "Available targets:"
	@echo "  config     - Show current configuration"
	@echo "  build      - Build all images"
	@echo "  up         - Start services"
	@echo "  rebuild    - Start services with rebuild"
	@echo "  down       - Stop services"
	@echo "  status     - Show service status and recent logs"
	@echo "  logs       - Follow service logs"
	@echo "  clean      - Remove containers and prune images"
	@echo "  versions   - Check dependency versions"
	@echo "  pre        - Pre-commit checks and sanitizing"
	@echo "  dev        - Start the development server"

# Show current configuration
config:
	@echo "Current configuration:"
	@echo "  DOCKER:             $(DOCKER)"
	@echo "  PROJECT_DIR:        $(PROJECT_DIR)"
	@echo "  IMAGE_NAME:         $(IMAGE_NAME)"
	@echo "  EXTERNAL_PORT:      $(EXTERNAL_PORT)"
	@echo "  APP_PUBLIC_URL:     $(APP_PUBLIC_URL)"
	@echo "  APP_REPOSITORY_URL: $(APP_REPOSITORY_URL)"
	@echo "  NODE_ENV:           $(NODE_ENV)"

# Build all images
build: pre
	$(COMPOSE) --profile app build

# Start services
up:
	$(COMPOSE) up --detach

# Start services with rebuild
rebuild: down
	$(COMPOSE) up --build --detach

# Stop services
down:
	$(COMPOSE) down

# Show service status and recent logs
status:
	@echo "=== Service Status ==="
	$(COMPOSE) ps
	@echo ""
	@echo "=== Recent Logs ==="
	$(COMPOSE) logs --tail=20

# Follow service logs
logs:
	$(COMPOSE) logs --follow

# Remove containers and prune images
clean:
	$(DOCKER) rm --all --force 2>/dev/null || true
	$(DOCKER) image prune --force

# Remove generated files (should not be necessary with .dockerignore)
prune:
# 	rm -rf $(PROJECT_DIR)/node_modules $(PROJECT_DIR)/_fresh $(PROJECT_DIR)/data
	rm -rf $(PROJECT_DIR)/node_modules $(PROJECT_DIR)/_fresh $(PROJECT_DIR)/deno.lock

# Helper function for printing lastest version from jsr.io for a package
define get_latest_version
	@printf "Latest $(1) version: "
	@curl -s 'https://jsr.io/$(1)/meta.json' | jq -r '.versions | keys[]' | sort -V | tail -n1
endef

# Show depenency versions to alert for outdated packages
versions:
	@cd $(PROJECT_DIR) && deno task check-deps || true
	$(call get_latest_version,@fresh/core)
# 	$(call get_latest_version,@fresh/plugin-tailwind)

# Pre-commit checking and sanitizing
pre:
	@cd $(PROJECT_DIR) && deno install --allow-scripts && deno task build && deno task check

# Start the development server
dev:
	@cd $(PROJECT_DIR) && APP_PUBLIC_URL=http://localhost:5173 deno task dev

# Start the production server
serve:
	@cd $(PROJECT_DIR) && APP_PUBLIC_URL=http://localhost:8000 deno task serve

# Pull the latest Deno image
pull:
	$(DOCKER) pull docker.io/denoland/deno:latest

# Inspect the Vite production build
inspect:
	npx serve $(PROJECT_DIR)/.vite-inspect
