#!/bin/bash

# Pterodactyl Panel Updater Script
set -e

echo "⚠️  WARNING: This will update your Pterodactyl Panel to the latest version."
read -p "Do you want to continue? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "❌ Update cancelled by user."
    exit 0
fi

echo "[*] Starting Pterodactyl Panel update..."

cd /var/www/pterodactyl || { echo "[!] Directory not found."; exit 1; }

echo "[*] Putting panel into maintenance mode..."
php artisan down

echo "[*] Downloading and extracting the latest panel version..."
curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv

echo "[*] Setting permissions..."
chmod -R 755 storage/* bootstrap/cache

echo "[*] Installing dependencies..."
composer install --no-dev --optimize-autoloader

echo "[*] Clearing caches..."
php artisan view:clear
php artisan config:clear

echo "[*] Migrating and seeding..."
php artisan migrate --seed --force

echo "[*] Fixing permissions..."
chown -R www-data:www-data /var/www/pterodactyl/*

echo "[*] Restarting queues..."
php artisan queue:restart

echo "[*] Bringing the panel back online..."
php artisan up

echo "[✓] Pterodactyl Panel successfully updated!"
