# Use a minimal base image suitable for running in OpenShift
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

# Set labels for OpenShift (optional but recommended)
LABEL maintainer="Your Name" \
      io.openshift.expose-services="80:http" \
      io.openshift.tags="nginx"

# Install required packages
RUN microdnf update -y && \
    microdnf install -y nginx unzip curl ca-certificates && \
    microdnf clean all

# Set Nginx to run in the foreground
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Set the working directory
WORKDIR /var/www/html/

# Download and extract the 2048 game
RUN curl -o master.zip -L https://codeload.github.com/gabrielecirulli/2048/zip/master && \
    unzip master.zip && \
    mv 2048-master/* . && \
    rm -rf 2048-master master.zip

# Expose the port
EXPOSE 8080

# Create a new user and group
RUN groupadd -r nginx && \
    useradd -r -g nginx nginx

# Change ownership of relevant directories
RUN chown -R nginx:nginx /var/www/html && \
    chmod -R 755 /var/www/html

# Start Nginx as the new user
USER nginx

# Start Nginx
CMD ["nginx", "-c", "/etc/nginx/nginx.conf"]
