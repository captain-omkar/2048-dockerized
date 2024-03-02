FROM ubuntu:latest
ARG UID
ARG GID

# Update the package list, install sudo, create a non-root user, and grant password-less sudo permissions
RUN apt update && \
    apt install -y sudo && \
    addgroup --gid $GID nonroot && \
    adduser --uid $UID --gid $GID --disabled-password --gecos "" nonroot && \
    echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set the non-root user as the default user
USER nonroot

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx unzip curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/user www-data;/worker_processes 1;\nuser www-data;/' /etc/nginx/nginx.conf \
    && sed -i 's/# server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf \
    && sed -i 's|/var/lib/nginx/body|/tmp/nginx|g' /etc/nginx/nginx.conf

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

WORKDIR /var/www/html/

RUN curl -o master.zip -L https://codeload.github.com/gabrielecirulli/2048/zip/master

RUN unzip master.zip && mv 2048-master/* . && rm -rf 2048-master master.zip

EXPOSE 80

CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
