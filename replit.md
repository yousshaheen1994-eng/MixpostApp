# Mixpost Lite

A self-hosted social media management application built with Laravel 12. Schedule and publish content across social platforms.

## Tech Stack

- **Backend**: Laravel 12 (PHP 8.2)
- **Database**: PostgreSQL (Replit managed)
- **Frontend**: Pre-built Vue.js assets via the `inovector/mixpost` composer package
- **Queue**: Sync (no Redis required for development)

## Project Structure

```
app/          - Laravel application code
config/       - Laravel configuration files
database/     - Migrations and seeders
public/       - Web root (entry point + pre-built vendor assets)
resources/    - Blade views and source frontend assets
routes/       - Route definitions
vendor/       - Composer dependencies (incl. mixpost package)
start.sh      - Startup script (generates .env, runs migrations, starts server)
```

## Running the App

The app is started via `bash start.sh` which:
1. Generates a `.env` file from environment variables
2. Runs database migrations
3. Clears caches
4. Starts `php artisan serve` on port 5000

## Environment Variables

The following are set via Replit secrets/env vars:
- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE` — PostgreSQL credentials (auto-set by Replit DB)
- `APP_NAME`, `APP_DEBUG`, `APP_ENV`, etc. — set via Replit env vars

## First-Time Setup

After starting the app, create an admin user by running:
```
php artisan mixpost:create-user
```

Or visit `/mixpost` and follow the setup wizard.

## User Preferences

- Use PostgreSQL (Replit managed database) instead of MySQL
- Queue connection is `sync` (no Redis required in dev)
- Use `php artisan serve` for development server on port 5000
