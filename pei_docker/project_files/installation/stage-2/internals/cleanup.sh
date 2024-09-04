#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/cleanup.sh ..."

# if REMOVE_GLOBAL_PROXY_AFTER_BUILD is true, remove the global proxy settings
if [ "$REMOVE_GLOBAL_PROXY_AFTER_BUILD" = "true" ]; then
    # check if the proxy settings file exists
    if [ -f /etc/profile.d/proxy.sh ]; then
        echo "Removing proxy settings from /etc/profile.d/proxy.sh..."
        
        # remove the proxy settings file
        rm -f /etc/profile.d/proxy.sh
    fi

    # find http_proxy, https_proxy, HTTP_PROXY, HTTPS_PROXY in /etc/environment
    # then remove them
    if [ -f /etc/environment ]; then
        echo "Removing http_proxy and https_proxy from /etc/environment..."
        
        # remove http_proxy and https_proxy from /etc/environment
        sed -i '/http_proxy/d' /etc/environment
        sed -i '/https_proxy/d' /etc/environment
        sed -i '/HTTP_PROXY/d' /etc/environment
        sed -i '/HTTPS_PROXY/d' /etc/environment
    fi
fi