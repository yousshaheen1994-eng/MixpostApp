#!/bin/bash
set -e

# Generate .env from environment variables
cat > .env << EOF
APP_NAME='Mixpost'
APP_KEY=base64:3+tRrwP6ToQ4HGkkm4TZv0JzEpgBBlUjpXfXmiq9iBU=
APP_DEBUG=true
APP_ENV=local
APP_URL=http://localhost:5000

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=pgsql
DB_HOST=${PGHOST}
DB_PORT=${PGPORT}
DB_DATABASE=${PGDATABASE}
DB_USERNAME=${PGUSER}
DB_PASSWORD=${PGPASSWORD}

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="Mixpost"

MIXPOST_DISK=public
EOF

# Fix storage permissions
chmod -R 775 storage bootstrap/cache

# Create storage link if not exists
php artisan storage:link --quiet 2>/dev/null || true

# Run migrations
php artisan migrate --force --no-interaction

# Clear caches
php artisan config:clear
php artisan cache:clear

# Start the PHP built-in server on port 5000
php artisan serve --host=0.0.0.0 --port=5000
