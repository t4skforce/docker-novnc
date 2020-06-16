# fix permissions
PUID=${PUID:-1000}
PGID=${PGID:-1000}
groupmod -o -g "$PGID" app
usermod -o -u "$PUID" app

if [ ! "$(stat -c %u $HOME)" = "$PUID" ]; then
    echo "Change in ownership detected, please be patient while we chown existing files"
  	echo "This could take some time"
  	chown app:app -R $HOME
fi

if [ ! "$(stat -c %u /dev/stdout)" = "$PUID" ]; then
  chown app:app /dev/stdout
fi

# copy data from skel folder for default home files
while IFS="'" read -r a src c target ; do
  target=$(realpath "$target")
  if [ -d "$target" ];then
    chown app:app -R "$target"
  fi
  if [ -f "$target" ];then
    chown app:app "$target"
  fi
done < <(cp -rv "/etc/skel/." "$HOME")
