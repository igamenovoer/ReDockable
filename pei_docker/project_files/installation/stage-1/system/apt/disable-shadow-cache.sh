#!/bin/bash

# disable shadow cache, created by enable-shadow-cache.sh
if [ -f /etc/apt/apt.conf.d/01-shadow-cache ]; then
    rm /etc/apt/apt.conf.d/01-shadow-cache
fi
echo "Shadow cache disabled"

