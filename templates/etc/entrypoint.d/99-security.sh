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
while IFS='=' read -r key value ; do
  [[ $key =~ ^#.* ]] && continue
  export "$key=$value"
done < "/etc/environment"

# load openbox env file
source /etc/xdg/openbox/environment

# print startup
echo "
-------------------------------------
User uid:    $(id -u app)
User gid:    $(id -g app)
-------------------------------------
"
