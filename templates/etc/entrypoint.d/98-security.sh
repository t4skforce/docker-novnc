###############################################
# Permissions
###############################################
# set folder content to read only
chmod 0444 /usr/share/applications/* /etc/xdg/autostart/*

###############################################
# Environment variables
###############################################
# remove all env variables
while IFS='=' read -r key value ; do
  [[ $key == "PATH" ]] || [[ $key == "HOSTNAME" ]] || [[ $key == "PWD" ]] || [[ $key == "HOME" ]] && continue
  unset "$key"
done < <(env)
# load clean env variables
source /etc/entrypoint.d/20-environment.sh
source /etc/xdg/openbox/environment
