#!/bin/bash
set -e

# run hooks
for hook in $(find /etc/entrypoint.d/ -executable -type f | sort); do
  echo "- $(basename $hook)"
  source $hook
done

case "${1,,}" in
  supervisord) exec supervisord -c /etc/supervisord.conf ;; # 0 = true
  *) exec "$@" ;;
esac
