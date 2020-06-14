#!/bin/bash
set -e

PUID=${PUID:-1000}
PGID=${PGID:-1000}
groupmod -o -g "$PGID" app
usermod -o -u "$PUID" app

function getboolean() {
  case "${1,,}" in
    true) return 0 ;; # 0 = true
    t) return 0 ;; # 0 = true
    yes) return 0 ;; # 0 = true
    y) return 0 ;; # 0 = true
    1) return 0 ;; # 0 = true
    *) return 1 ;;
   esac
}

# check permissions
if [ ! "$(stat -c %u $HOME)" = "$PUID" ]; then
    echo "Change in ownership detected, please be patient while we chown existing files"
  	echo "This could take some time"
  	chown app:app -R $HOME
fi
if [ ! "$(stat -c %u /dev/stdout)" = "$PUID" ]; then
  chown app:app /dev/stdout
fi


# setup cert
export SERVER_NAME=${SERVER_NAME-$HOSTNAME}
if getboolean "$REVERSE_PROXY"; then
  if [ ! -d "$HOME/.cert/server.key" ]; then
    echo "creating self signed certificate $HOME/.cert/nginx.crt"
    mkdir -p $HOME/.cert
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
      -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${SERVER_NAME}" \
      -keyout "$HOME/.cert/server.key" -out "$HOME/.cert/server.crt"
  fi
  # add basic auth ir requests
  if [ ! -z "$APP_USERNAME" ]; then
    if [ ! -f "$HOME/.htpasswd" ]; then
      touch "$HOME/.htpasswd"
    fi
    htpasswd -db "$HOME/.htpasswd" $APP_USERNAME $APP_PASSWORD
  fi
fi

# render templates
template-render env /etc/xdg/openbox/environment.j2 /etc/nginx/nginx.conf.j2 /etc/gtk-2.0/gtkrc.j2 /etc/gtk-3.0/settings.ini.j2
template-render desktop --no-visibility /usr/share/applications /etc/supervisord.conf.j2 /etc/cron.d/cronjobs.j2
template-render desktop --no-visibility /etc/xdg/autostart /etc/xdg/openbox/autostart.j2
template-render desktop /usr/share/applications /etc/xdg/openbox/menu.xml.j2 /etc/xdg/openbox/rc.xml.j2 /etc/tint2rc.j2 && \
mkdir -p $HOME/.config/tint2 && \
cp /etc/tint2rc $HOME/.config/tint2/tint2rc

echo "
-------------------------------------
User uid:    $(id -u app)
User gid:    $(id -g app)
-------------------------------------
"

export NO_AT_BRIDGE=1

case "${1,,}" in
  supervisord) exec supervisord -c /etc/supervisord.conf ;; # 0 = true
  *) exec "$@" ;;
esac
