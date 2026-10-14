FROM dunglas/frankenphp:1-php8.4

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip \
    && rm -rf /var/lib/apt/lists/* \
    && install-php-extensions zip

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APP_ENV=prod \
    APP_DEBUG=0 \
    APP_SECRET=reproducer

WORKDIR /app
COPY . /app
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress
