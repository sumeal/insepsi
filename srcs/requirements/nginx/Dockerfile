FROM debian:bookworm

RUN apt-get update -y && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh && /tmp/setup.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
