#!/bin/sh
# this script sets up all environment variables, as well as configuration files
# based on the environment variables

# if APT_USE_PROXY is true, set up proxy for apt
# the proxy is given in USER_HTTP_PROXY and USER_HTTPS_PROXY
if [ -n "$APT_USE_PROXY" ]; then
  # if USER_HTTP_PROXY is not set, or USER_HTTPS_PROXY is not set
  # skip
  if [ -z "$USER_HTTP_PROXY" ] || [ -z "$USER_HTTPS_PROXY" ]; then
    echo "USER_HTTP_PROXY and USER_HTTPS_PROXY must be set if APT_USE_PROXY is true"
    echo "Skipping proxy setup for apt"    
  else
    echo "Setting up proxy for apt"
    echo "Acquire::http::Proxy \"$USER_HTTP_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf
    echo "Acquire::https::Proxy \"$USER_HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf

    echo "/etc/apt/apt.conf.d/proxy.conf:"
    cat /etc/apt/apt.conf.d/proxy.conf
  fi
fi

# if you want to use proxy in shell, just use ENV in your dockerfile

# if APT_SOURCE_FILE is set, use it to replace /etc/apt/sources.list
if [ -n "$APT_SOURCE_FILE" ]; then
  echo "Using $APT_SOURCE_FILE as /etc/apt/sources.list"

  # backup the original sources.list
  cp /etc/apt/sources.list /etc/apt/sources.list.bak

  # copy the new sources.list
  cp $APT_SOURCE_FILE /etc/apt/sources.list
fi

# create a list containing contents of environment variables
# X_PATH_APPS, X_PATH_DATA, X_PATH_WORKSPACE
dirs_to_create="$X_PATH_SOFT_BASE/$X_PREFIX_APPS" \
  "$X_PATH_SOFT_BASE/$X_PREFIX_DATA" \
  "$X_PATH_SOFT_BASE/$X_PREFIX_WORKSPACE" \
  "$X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_APPS" \
  "$X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_DATA" \
  "$X_PATH_HARD_BASE/$X_PREFIX_IMAGE_STORAGE/$X_PREFIX_WORKSPACE" \
  "$X_PATH_HARD_BASE/$X_PREFIX_VOLUME_STORAGE"

# for each dir in soft_dirs, create it if it doesn't exist
for dir in $dirs_to_create; do
  if [ ! -d "$dir" ]; then
    echo "Creating $dir"
    mkdir -p $dir

    # allow anyone to read, write, and execute
    chmod -R 777 $dir
  fi
done