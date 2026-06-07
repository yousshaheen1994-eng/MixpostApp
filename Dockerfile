# Dockerfile — Railway deployment
#
# PHP 8.2 with ALL extensions required by Laravel + Mixpost + Horizon.
# Extensions added: pdo_mysql, redis (PECL), opcache, sockets, mbstring.

FROM php:8.2-cli

# ── System libraries ──────────────────────────────────────────────────────────
# libpq-dev      → pdo_pgsql / pgsql
# libzip-dev     → zip
# libxml2-dev    → xml
# libpng-dev     → gd
# libonig-dev    → mbstring
# libmariadb-dev → pdo_mysql (MariaDB-compatible MySQL client)
# autoconf/make  → needed by PECL (redis build)
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        zip \
        unzip \
        autoconf \
        make \
        g++ \
        libpq-dev \
        libzip-dev \
        libxml2-dev \
        libpng-dev \
        libonig-dev \
        libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# ── Built-in PHP extensions (docker-php-ext-install) ─────────────────────────
RUN docker-php-ext-install \
        pcntl \
        pdo \
        pdo_pgsql \
        pgsql \
        pdo_mysql \
        mbstring \
        sockets \
        exif \
        bcmath \
        xml \
        zip \
        fileinfo \
        gd

# ── OPcache (already compiled into PHP — just enable it) ─────────────────────
RUN docker-php-ext-enable opcache \
    && echo "opcache.enable=1"            >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=0"  >> /usr/local/etc/php/conf.d/opcache.ini

# ── Redis (PECL — not available via docker-php-ext-install) ──────────────────
RUN pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

# ── Composer 2 ────────────────────────────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ── Application ───────────────────────────────────────────────────────────────
WORKDIR /var/www

COPY . .

# Install PHP dependencies (production, no dev packages)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Publish Mixpost package assets + migrations (best-effort at build time)
RUN php artisan mixpost:publish --no-interaction 2>/dev/null || true

EXPOSE 8080

# ── Runtime entrypoint ────────────────────────────────────────────────────────
# Railway injects all env vars at runtime.
# Order: migrate → cache config+routes → start server on $PORT.
CMD ["/bin/bash", "-c", \
    "php artisan migrate --force --no-interaction \
     && php artisan config:cache \
     && php artisan route:cache \
     && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
