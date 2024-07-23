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
fi