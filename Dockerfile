FROM ubuntu:latest

ARG USERNAME=user-name-goes-here
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx unzip curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

WORKDIR /var/www/html/

RUN curl -o master.zip -L https://codeload.github.com/gabrielecirulli/2048/zip/master

RUN unzip master.zip && mv 2048-master/* . && rm -rf 2048-master master.zip

EXPOSE 80

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
