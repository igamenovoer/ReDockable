#!/bin/bash
# this script sets up all environment variables, as well as configuration files
# based on the environment variables

# if ENABLE_GLOBAL_PROXY is true, set up proxy for all users
if [ "$ENABLE_GLOBAL_PROXY" = "true" ]; then
  # if PEI_HTTP_PROXY_2 is not set, or PEI_HTTPS_PROXY_2 is not set
  # skip
  if [ -z "$PEI_HTTP_PROXY_2" ] || [ -z "$PEI_HTTPS_PROXY_2" ]; then
    echo "PEI_HTTP_PROXY_2 and PEI_HTTPS_PROXY_2 must be set if ENABLE_PROXY_IN_BUILD is true"
    echo "Skipping proxy setup for build"
  else
    echo "Setting up proxy for build, write to profile.d"
    echo "export http_proxy=$PEI_HTTP_PROXY_2" >> /etc/profile.d/proxy.sh
    echo "export https_proxy=$PEI_HTTPS_PROXY_2" >> /etc/profile.d/proxy.sh
    echo "export HTTP_PROXY=$PEI_HTTP_PROXY_2" >> /etc/profile.d/proxy.sh
    echo "export HTTPS_PROXY=$PEI_HTTPS_PROXY_2" >> /etc/profile.d/proxy.sh
  fi
elif [ "$ENABLE_GLOBAL_PROXY" = "false" ]; then
  # check if the proxy settings file exists, if yes, remove it
  if [ -f /etc/profile.d/proxy.sh ]; then
    echo "Removing proxy settings from /etc/profile.d/proxy.sh..."
    
    # remove the proxy settings file
    rm -f /etc/profile.d/proxy.sh
  fi
fi