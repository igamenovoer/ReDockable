#!/bin/bash
# this script sets up all environment variables, as well as configuration files
# based on the environment variables

# set root password as ROOT_PASSWORD if it is not empty
if [ -n "$ROOT_PASSWORD" ]; then
  echo "Setting root password as $ROOT_PASSWORD"
  echo "root:$ROOT_PASSWORD" | chpasswd
fi

# if APT_USE_PROXY is true, set up proxy for apt
# the proxy is given in USER_HTTP_PROXY and USER_HTTPS_PROXY
if [ "$APT_USE_PROXY" = "true" ]; then
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