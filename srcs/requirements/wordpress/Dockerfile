# Use Debian Bookworm
FROM debian:bookworm

# Install PHP, FPM, and required extensions
RUN apt-get update -y && apt-get install -y \
    wget \
    php \
    php-fpm \
    php-mysqli \
    mariadb-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy setup script
COPY tools/setup.sh /tmp/setup.sh

# Make it executable
RUN chmod +x /tmp/setup.sh

# Run setup script (configure WordPress)
CMD ["/tmp/setup.sh"]
