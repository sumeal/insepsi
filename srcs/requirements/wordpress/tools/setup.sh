#!/bin/bash
set -e

# Wait until the database is reachable
until mysqladmin ping -h "${WORDPRESS_DB_HOST%%:*}" --silent; do
  sleep 1
done

# Download WordPress if directory is empty
if [ ! -f index.php ] || [ ! -d wp-includes ]; then
  rm -rf ./*
  wget -q https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz --strip-components=1
  rm latest.tar.gz
  chown -R www-data:www-data /var/www/html
fi

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST%%:*}/" wp-config.php

  # Add secret keys
  AUTH_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
  echo "$AUTH_KEYS" >> wp-config.php
  chown www-data:www-data wp-config.php
fi

# Install WP-CLI if not already present
if [ ! -f /usr/local/bin/wp ]; then
  curl -s -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x /usr/local/bin/wp
fi

# Run initial WordPress installation
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  wp core install --url="${WP_URL}" --title="${WP_TITLE:-Inception}" \
    --admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root || true
fi

# Fix permissions and start PHP-FPM
chown -R www-data:www-data /var/www/html
exec "$@"
