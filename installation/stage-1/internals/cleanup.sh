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

# if KEEP_APT_SOURCE_FILE is not equal to true, remove the custom sources.list
# recover the original sources.list from the backup
if [ "$KEEP_APT_SOURCE_FILE" != "true" ]; then
    # check if the backup sources.list file exists
    if [ -f /etc/apt/sources.list.bak ]; then
        echo "Recovering the original /etc/apt/sources.list from the backup..."
        
        # recover the original sources.list from the backup
        mv -f /etc/apt/sources.list.bak /etc/apt/sources.list
    fi
fi