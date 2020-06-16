# setup cert
export SERVER_NAME=${SERVER_NAME-$HOSTNAME}
if getboolean "$REVERSE_PROXY"; then
  if [ ! -d "$HOME/.cert/server.key" ]; then
    echo "creating self signed certificate $HOME/.cert/nginx.crt"
    mkdir -p $HOME/.cert
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
      -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${SERVER_NAME}" \
      -keyout "$HOME/.cert/server.key" -out "$HOME/.cert/server.crt"
    chown app:app "$HOME/.cert/server.key" "$HOME/.cert/server.crt"
  fi
  # add basic auth ir requests
  if [ ! -z "$APP_USERNAME" ]; then
    if [ ! -f "$HOME/.htpasswd" ]; then
      touch "$HOME/.htpasswd"
      chown app:app "$HOME/.htpasswd"
    fi
    htpasswd -db "$HOME/.htpasswd" $APP_USERNAME $APP_PASSWORD
  fi
else
  # remove nginx auth entry if not required
  if [ -f "/usr/share/applications/access.desktop" ]; then
    rm -f "/usr/share/applications/access.desktop"
  fi
  if [ -f "/usr/bin/basic_auth" ]; then
    rm -f "/usr/bin/basic_auth"
  fi
fi
