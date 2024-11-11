include mysql/mysql.env

DOCKER_COMPOSE=docker-compose  # Change to use docker-compose

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=${MYSQL_DATABASE}
DB_USERNAME=${MYSQL_USER}
DB_PASSWORD=${MYSQL_PASSWORD}

clean:
	${DOCKER_COMPOSE} down

all: clean app mysql-wait npm-build composer-install composer-migrate-fresh composer-seed composer-key-generate

mysql-wait:
	sleep 5

init:
	mkdir -p web
	${DOCKER_COMPOSE} run --rm --build composer create-project laravel/laravel .

purge:
	sudo rm -rf web  # Make sure to put a space between -rf

app:
	${DOCKER_COMPOSE} up -d --build app

phpmyadmin:
	${DOCKER_COMPOSE} up -d --build phpmyadmin

npm-build:
	${DOCKER_COMPOSE} run --build --rm npm install	
	${DOCKER_COMPOSE} run --build --rm npm run build

composer-install:
	${DOCKER_COMPOSE} run --build --rm composer install

composer-migrate-fresh:
	${DOCKER_COMPOSE} run --build --rm artisan migrate:fresh

composer-seed:
	${DOCKER_COMPOSE} run --build --rm artisan db:seed
	${DOCKER_COMPOSE} run --build --rm artisan db:seed --class=NoteSeeder
	
composer-key-generate:
	${DOCKER_COMPOSE} run --build --rm artisan key:generate

env:
	cp web/.env.example web/.env
	sed -i 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' web/.env
	sed -i 's/# DB_HOST=127.0.0.1/DB_HOST=mysql/' web/.env
	sed -i 's/# DB_PORT=3306/DB_PORT=3306/' web/.env
	sed -i 's/# DB_DATABASE=laravel/DB_DATABASE=${MYSQL_DATABASE}/' web/.env
	sed -i 's/# DB_USERNAME=root/DB_USERNAME=${MYSQL_USER}/' web/.env
	sed -i 's/# DB_PASSWORD=/DB_PASSWORD=${MYSQL_PASSWORD}/' web/.env

