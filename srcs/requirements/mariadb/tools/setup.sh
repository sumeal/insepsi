#!/bin/bash
set -e

# Ensure correct permissions for MySQL directories
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld || true
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

# Initialize database only if it's empty
if [ -z "$(ls -A /var/lib/mysql)" ]; then
  mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

  # Start a temporary server to run setup SQL
  mysqld_safe --datadir=/var/lib/mysql --skip-networking=false &
  pid="$!"

  # Wait until server is ready
  until mysqladmin ping --silent; do
    sleep 1
  done

  # Create database, users, and grant privileges
  mysql <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` ;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  # Shut down temporary server
  mysqladmin shutdown
fi

# Run MySQL server in foreground (PID 1)
exec mysqld --datadir=/var/lib/mysql
