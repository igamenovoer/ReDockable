#!/bin/bash

# disable external cache, created by enable-external-cache.sh
if [ -f /etc/apt/apt.conf.d/01-external-cache ]; then
    rm /etc/apt/apt.conf.d/01-external-cache
fi
echo "External cache disabled"

