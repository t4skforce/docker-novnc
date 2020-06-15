#!/bin/bash
# loading environment variables
while IFS='=' read -r key value ; do
  [[ $key =~ ^#.* ]] && continue
  export "$key=$value"
done < "/etc/environment"
