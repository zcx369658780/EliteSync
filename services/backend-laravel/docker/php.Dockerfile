FROM php:8.5.3-fpm

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libonig-dev \
    libicu-dev \
    libpng-dev \
    libxml2-dev \
    default-mysql-client \
    && docker-php-ext-install pdo_mysql bcmath intl zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.7.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
