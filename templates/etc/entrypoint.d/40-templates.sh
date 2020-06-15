# render templates
template-render env /etc/xdg/openbox/environment.j2 /etc/nginx/nginx.conf.j2 /etc/gtk-2.0/gtkrc.j2 /etc/gtk-3.0/settings.ini.j2
template-render desktop --no-visibility /etc/xdg/autostart /etc/xdg/openbox/autostart.j2
template-render desktop --no-visibility /usr/share/applications /etc/supervisord.conf.j2 /etc/cron.d/cronjobs.j2
template-render desktop /usr/share/applications /etc/xdg/openbox/menu.xml.j2 /etc/xdg/openbox/rc.xml.j2 /etc/tint2rc.j2 && \
mkdir -p $HOME/.config/tint2 && cp /etc/tint2rc $HOME/.config/tint2/tint2rc
