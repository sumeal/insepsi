# Use Debian Bookworm as base image
FROM debian:bookworm

# Install MariaDB server
RUN apt-get update -y && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

# Copy setup script
COPY tools/setup.sh /tmp/setup.sh

# Make it executable
RUN chmod +x /tmp/setup.sh

# Run setup script at container start
CMD ["/tmp/setup.sh"]
