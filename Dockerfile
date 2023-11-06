FROM golang:latest AS easy-novnc-build
WORKDIR /src
RUN set -xe && \
    go mod init build && \
    go get github.com/geek1011/easy-novnc && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM debian:stable-slim

ARG BUILD_DATE="2023-11-06T16:04:06Z"

ENV HOME=/data \
    PUID=1000 \
    PGID=1000 \
    HTTP_PORT=8080 \
    HTTPS_PORT=8443 \
    REVERSE_PROXY=yes \
    CRONJOBS=yes \
    VNC_EXPOSE=no \
    OPENBOX_THEME_NAME=Nightmare \
    OPENBOX_ICON_THEME_NAME=Papirus-Dark \
    OPENBOX_THEME_FONT="DejaVu Sans 9"

RUN set -xe && \
    sed -i "s# main# main contrib non-free#g" /etc/apt/sources.list && \
    apt-get update -y && \
    mkdir -p /usr/share/desktop-directories /usr/share/man/man1 && \
    apt-get install -y --no-install-recommends \
      openbox python3-xdg obconf tint2 feh papirus-icon-theme arc-theme \
      tigervnc-standalone-server supervisor cron python3-jinja2 python3-click \
      terminator nano wget curl ca-certificates xdg-utils htop tar fonts-dejavu \
      nginx-light gettext-base apache2-utils && \
    rm -rf /usr/share/themes/*/{cinnamon,gnome-shell,unity,xfwm4,plank} \
       /usr/share/icons/{Adwaita,HighContrast,Papirus,Papirus-Light,ePapirus,hicolor} \
       /etc/systemd/**/*.service \
       /usr/lib/python*/**/*.pyc \
       /etc/nginx/nginx.conf \
       /etc/xdg/autostart/* \
       /etc/xdg/openbox/* \
       /var/lib/apt/lists

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY ./templates/. /
RUN set -xe && \
    chmod 0644 /etc/cron.d/*.j2 /etc/nginx/*.j2 /etc/xdg/openbox/*.j2 /etc/*.j2 && \
    chmod 0700 /etc/entrypoint.d && \
    chmod 0444 /usr/share/applications/* /etc/xdg/autostart/* && \
    groupadd --gid ${PGID} app && \
    useradd --home-dir ${HOME} --shell /bin/bash --uid ${PUID} --gid ${PGID} app && \
    mkdir -p ${HOME}

WORKDIR ${HOME}
VOLUME ${HOME}

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "supervisord" ]
