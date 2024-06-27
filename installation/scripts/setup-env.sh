#!/bin/sh
# this script sets up all environment variables, as well as configuration files
# based on the environment variables

# do we need to use proxy for apt?
if [ -n "$APT_HTTP_PROXY" ]; then
  echo "Setting up proxy for apt"
  echo "Acquire::http::Proxy \"$APT_HTTP_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf
  echo "Acquire::https::Proxy \"$APT_HTTP_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf

  echo "/etc/apt/apt.conf.d/proxy.conf:"
  cat /etc/apt/apt.conf.d/proxy.conf
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