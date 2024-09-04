#!/bin/bash
# clean up intermediate files

# if APT_KEEP_PROXY is not equal to true, remove the proxy settings file
if [ "$APT_KEEP_PROXY" != "true" ]; then
    # check if the proxy settings file exists
    if [ -f /etc/apt/apt.conf.d/proxy.conf ]; then
        echo "Removing proxy settings from /etc/apt/apt.conf.d/proxy.conf..."
        
        # remove the proxy settings file
        rm -f /etc/apt/apt.conf.d/proxy.conf
    fi
fi

# apt source file, it can be /etc/apt/sources.list or /etc/apt/sources.list.d/ubuntu.sources
# see which file exists, check /etc/apt/sources.list.d/ubuntu.sources first
CURRENT_APT_SOURCE=/etc/apt/sources.list
if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
  echo "/etc/apt/sources.list.d/ubuntu.sources exists"
  CURRENT_APT_SOURCE="/etc/apt/sources.list.d/ubuntu.sources"
fi

# if KEEP_APT_SOURCE_FILE is not equal to true, remove the custom sources.list
# recover the original sources.list from the backup
if [ "$KEEP_APT_SOURCE_FILE" != "true" ]; then
    # check if the backup sources.list file exists
    if [ -f /etc/apt/sources.list.bak ]; then
        echo "Recovering the original $CURRENT_APT_SOURCE from the backup..."
        
        # recover the original sources.list from the backup
        mv -f "$CURRENT_APT_SOURCE.bak" "$CURRENT_APT_SOURCE"
    fi
fi

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