# Mixpost Lite

A self-hosted social media management application built with Laravel 12. Create, schedule, and publish content across social media platforms.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Laravel 12 (PHP 8.2) |
| Database | PostgreSQL (Replit managed) |
| Frontend | Pre-built Vue.js + Inertia.js (via `inovector/mixpost` package) |
| Queue | Sync (no Redis required) |
| Auth | `inovector/mixpost-auth` package |
| Assets | Pre-compiled — served from `public/vendor/mixpost/` |

## Project Structure

```
app/
  Http/Middleware/TrustProxies.php  — set to '*' for Replit reverse-proxy
config/                             — Laravel configuration files
database/migrations/                — Core + Mixpost table migrations
public/vendor/mixpost/              — Pre-built Mixpost Vue/JS assets
public/vendor/mixpost-auth/         — Pre-built auth assets
resources/views/index.blade.php     — Root Blade view (empty, package handles it)
routes/web.php                      — Root redirect → /mixpost
vendor/inovector/mixpost/           — Mixpost core package
vendor/inovector/mixpost-auth/      — Mixpost auth package
start.sh                            — Startup script (run on every boot)
```

## Running the App

The workflow runs `bash start.sh` which automatically:

1. Generates `.env` from Replit environment variables (PostgreSQL, REPLIT_DEV_DOMAIN)
2. Fixes storage/cache permissions
3. Creates the `public/storage` symlink
4. Publishes Mixpost package migrations (idempotent — safe every boot)
5. Runs all pending database migrations
6. Clears config, cache, and view caches
7. Starts `php artisan serve` on `0.0.0.0:5000`

## First-Time Setup — Create Admin User

After the app starts, open the Replit **Shell** tab and run:

```bash
php artisan mixpost-auth:create
```

You will be prompted for name, email, and password. Then log in at `/mixpost/login`.

## Available Artisan Commands

### Mixpost-specific
```bash
php artisan mixpost-auth:create           # Create admin user (first-time setup)
php artisan mixpost-auth:delete           # Delete a user
php artisan mixpost-auth:password         # Change a user's password
php artisan mixpost:publish               # Re-publish all Mixpost assets & migrations
php artisan mixpost:publish-assets        # Re-publish compiled JS/CSS assets only
php artisan mixpost:run-scheduled-posts   # Manually trigger scheduled post publishing
php artisan mixpost:clear-services-cache  # Clear social service cache
php artisan mixpost:clear-settings-cache  # Clear settings cache
php artisan mixpost:delete-old-data       # Prune old social provider data
php artisan mixpost:prune-temporary-directory  # Clean temp uploads
```

### Standard Laravel
```bash
php artisan migrate                 # Run pending migrations
php artisan migrate:status          # Show migration status
php artisan cache:clear             # Clear application cache
php artisan config:clear            # Clear config cache
php artisan route:list              # List all registered routes
php artisan tinker                  # Interactive REPL for the app
php artisan about                   # Show app environment summary
```

## Environment Variables

All variables are auto-generated in `.env` by `start.sh` at boot. Sources:

| Variable | Source | Description |
|----------|--------|-------------|
| `PGHOST` / `PGPORT` / `PGUSER` / `PGPASSWORD` / `PGDATABASE` | Replit secrets (auto) | PostgreSQL credentials |
| `REPLIT_DEV_DOMAIN` | Replit runtime (auto) | Sets `APP_URL` for correct link generation |
| `APP_KEY` | Hardcoded in `start.sh` | Laravel encryption key (fixed) |
| `QUEUE_CONNECTION=sync` | Hardcoded | No Redis needed in development |
| `MIXPOST_DISK=public` | Hardcoded | Media stored in `public/storage` |

## Route Map

| Route | Status | Notes |
|-------|--------|-------|
| `GET /` | 302 → `/mixpost` | Root redirect |
| `GET /mixpost` | 302 → `/mixpost/login` | Redirects to login if unauthenticated |
| `GET /mixpost/login` | 200 | Login page |
| `GET /mixpost/dashboard` | 302 → login / 200 | Requires auth |
| `GET /mixpost/posts` | 302 → login / 200 | Requires auth |
| `GET /mixpost/calendar` | 302 → login / 200 | Requires auth |
| `GET /mixpost/accounts` | 302 → login / 200 | Requires auth |
| `GET /mixpost/media` | 302 → login / 200 | Requires auth |
| `GET /mixpost/settings` | 302 → login / 200 | Requires auth |
| `GET /mixpost/reports` | 302 → login / 200 | Requires auth |

## Database

- **Type**: PostgreSQL (Replit managed, auto-provisioned)
- **Tables**: 18 total — 4 Laravel core + 14 Mixpost-specific (`mixpost_posts`, `mixpost_accounts`, `mixpost_settings`, etc.)
- Migrations run automatically on every boot (idempotent)

## Known Behaviours

- **npm / Vite build not needed**: Mixpost ships pre-compiled assets; the `npm` dependency `form-data@4.0.2` is blocked by Replit's security policy but is not required since assets are pre-built.
- **Dashboard 500 via curl**: Accessing `/mixpost/dashboard` with `curl` (no session cookie) produces a 500 from the Mixpost exception handler trying to share Inertia session state on an unauthenticated request. This is curl-only — a real browser session works correctly.
- **Proxy trust**: `TrustProxies::$proxies = '*'` so Replit's reverse proxy forwards headers correctly.

## User Preferences

- Use PostgreSQL (Replit managed database) instead of MySQL
- Queue connection is `sync` (no Redis required in development)
- Use `php artisan serve` on `0.0.0.0:5000` for the development server
