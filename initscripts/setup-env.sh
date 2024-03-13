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
  cp $APT_SOURCE_FILE /etc/apt/sources.list
fi