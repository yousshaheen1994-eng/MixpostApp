---
name: Mixpost migration publishing
description: Mixpost package migrations must be explicitly published before running migrate — they don't auto-discover.
---

The `inovector/mixpost` package does NOT auto-register its migrations for discovery by `php artisan migrate`. You must first run `php artisan mixpost:publish --no-interaction` which copies `vendor/inovector/mixpost/database/migrations/create_mixpost_tables.php` into `database/migrations/`. Only then will `php artisan migrate` create the 14 Mixpost-specific tables (mixpost_settings, mixpost_posts, etc.).

**Why:** The package intentionally uses `vendor:publish --tag=mixpost-migrations` instead of `loadMigrationsFrom()`, giving the app owner control over when the schema is applied.

**How to apply:** In `start.sh`, always run `php artisan mixpost:publish --no-interaction --quiet` before `php artisan migrate`. Use `|| true` so it doesn't fail if already published. This is idempotent — safe to run on every boot.
