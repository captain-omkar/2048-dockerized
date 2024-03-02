FROM ubuntu:latest

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
