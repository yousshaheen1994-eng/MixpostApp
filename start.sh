#!/bin/bash
set -e

# Generate .env from environment variables
cat > .env << EOF
APP_NAME='Mixpost'
APP_KEY=base64:3+tRrwP6ToQ4HGkkm4TZv0JzEpgBBlUjpXfXmiq9iBU=
APP_DEBUG=true
APP_ENV=local
APP_URL=https://${REPLIT_DEV_DOMAIN}

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
SESSION_SECURE_COOKIE=false

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="Mixpost"

MIXPOST_DISK=public
EOF

# Fix storage and cache permissions
chmod -R 775 storage bootstrap/cache

# Create storage symlink if it doesn't exist
php artisan storage:link --quiet 2>/dev/null || true

# Publish Mixpost package assets and migrations (idempotent — safe to run every time)
php artisan mixpost:publish --no-interaction --quiet 2>/dev/null || true

# Run all pending migrations (including Mixpost tables)
php artisan migrate --force --no-interaction

# Clear all caches to pick up fresh config
php artisan config:clear --quiet
php artisan cache:clear --quiet
php artisan view:clear --quiet

echo "✓ Mixpost is ready — visit /mixpost to get started"
echo "  To create your first admin user, run:"
echo "  php artisan mixpost-auth:create"

# Start the PHP development server on 0.0.0.0:5000
php artisan serve --host=0.0.0.0 --port=5000
