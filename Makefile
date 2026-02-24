# Makefile
.PHONY: help build up down shell logs test bundle console

help:
	@echo "Available commands:"
	@echo "  make build    - Build Docker images"
	@echo "  make up       - Start containers"
	@echo "  make down     - Stop containers"
	@echo "  make shell    - Open shell in app container"
	@echo "  make logs     - View container logs"
	@echo "  make bundle   - Run bundle install"
	@echo "  make test     - Run test suite"
	@echo "  make console  - Open Rails console"

build:
	docker-compose build

up:
	docker-compose up -d
	@echo "✅ Rails app: http://localhost:3000"
	@echo "✅ PHP bridge: http://localhost:8080/mysql_bridge.php"
	@echo "✅ MySQL: localhost:3306"

down:
	docker-compose down

shell:
	docker-compose exec app bash

logs:
	docker-compose logs -f

bundle:
	docker-compose exec app bundle _2.3.27_ install --path ${APP_ROOT}/ruby/gems

test:
	docker-compose exec app bundle exec ruby -I test test/models/persistence_test.rb

console:
	docker-compose exec app bundle exec rails console

migrate:
	docker-compose exec app bundle exec rails runner 'MysqlBridge.new.execute(File.read("db/schema.sql"))'

deploy-prepare:
	@echo "Preparing bundle for HostGator deployment..."
	docker-compose run --rm app bundle _2.3.27_ install --deployment --path ${APP_ROOT}/ruby/gems
	@echo "✅ Bundle ready in ./vendor/bundle"