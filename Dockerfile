FROM ubuntu:latest

# Install NGINX and other dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx unzip curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and group for NGINX
RUN groupadd -r nginx && useradd -r -g nginx nginx

# Adjust NGINX configuration
RUN sed -i 's/^user/#user/' /etc/nginx/nginx.conf \
    && sed -i 's/daemon/##daemon/' /etc/nginx/nginx.conf \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && mkdir -p /var/log/nginx \
    && touch /var/log/nginx/error.log \
    && chown -R nginx:nginx /var/log/nginx \
    && chmod -R 755 /var/log/nginx

# Set up NGINX application
WORKDIR /var/www/html/
RUN curl -o master.zip -L https://codeload.github.com/gabrielecirulli/2048/zip/master \
    && unzip master.zip && mv 2048-master/* . && rm -rf 2048-master master.zip

# Set proper permissions for NGINX directories
RUN chown -R nginx:nginx /var/www/html \
    && chown -R nginx:nginx /var/lib/nginx \
    && chmod -R 777 /var/www/html \
    && chmod -R 777 /var/lib/nginx

# Expose port 8080
EXPOSE 80

# Run NGINX as the non-root user
USER nginx

# Run NGINX
CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
