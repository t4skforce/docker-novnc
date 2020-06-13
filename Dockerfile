FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src
RUN set -xe && \
    go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM debian:buster-slim

ENV HOME=/data \
    PUID=1000 \
    PGID=1000 \
    HTTP_PORT=80 \
    HTTPS_PORT=443

RUN set -xe && \
    apt-get update -y && \
    mkdir -p /usr/share/desktop-directories /usr/share/man/man1 && \
    apt-get install -y --no-install-recommends \
      openbox obconf tint2 feh papirus-icon-theme arc-theme \
      tigervnc-standalone-server supervisor cron python3-jinja2 python3-click \
      terminator nano wget curl openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip fonts-dejavu fonts-liberation2 \
      nginx-light gettext-base apache2-utils && \
    rm -rf /etc/nginx/nginx.conf && \
    rm -rf /etc/xdg/autostart/* /etc/xdg/openbox/* && \
    rm -rf /var/lib/apt/lists

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY ./templates/. /
RUN set -xe && \
    chmod 0644 /etc/cron.d/*.j2 /etc/nginx/*.j2 /etc/xdg/openbox/*.j2 /etc/*.j2 && \
    groupadd --gid ${PUID} app && \
    useradd --home-dir ${HOME} --shell /bin/bash --uid ${PUID} --gid ${PUID} app && \
    mkdir -p ${HOME}

WORKDIR ${HOME}
VOLUME ${HOME}

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD []
