# Dockerfile — Railway deployment (fallback if nixpacks.toml fails)
#
# Uses the official PHP 8.2 CLI image and explicitly installs pcntl
# plus all other extensions required by Laravel + Mixpost + Horizon.
#
# To use this instead of nixpacks.toml:
#   - Keep this file as-is
#   - Delete or rename nixpacks.toml
#   Railway will auto-detect the Dockerfile.

FROM php:8.2-cli

# Install system dependencies and ALL required PHP extensions in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl zip unzip \
        libpq-dev \
        libzip-dev \
        libxml2-dev \
        libpng-dev \
        libonig-dev \
    && docker-php-ext-install \
        pcntl \
        pdo \
        pdo_pgsql \
        pgsql \
        mbstring \
        exif \
        bcmath \
        xml \
        zip \
        fileinfo \
        gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer 2
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy project files
COPY . .

# Install PHP dependencies (no dev, optimised autoloader)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Publish Mixpost assets/migrations (best-effort — no .env yet at build time)
RUN php artisan mixpost:publish --no-interaction 2>/dev/null || true

EXPOSE 8080

# At runtime Railway injects all env vars; migrate then serve
CMD ["/bin/bash", "-c", "php artisan migrate --force --no-interaction && php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
