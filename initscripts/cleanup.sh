#!/bin/sh
# clean up intermediate files

# if APT_RETAIN_HTTP_PROXY is not equal to true, remove the proxy settings
if [ "$APT_RETAIN_HTTP_PROXY" != "true" ]; then
    # check if the proxy settings file exists
    if [ -f /etc/apt/apt.conf.d/proxy.conf ]; then
        echo "Removing proxy settings from /etc/apt/apt.conf.d/proxy.conf..."
        
        # remove the proxy settings file
        rm -f /etc/apt/apt.conf.d/proxy.conf
    fi
fi