#!/bin/bash

# Usage: ./enable-shadow-cache.sh [custom_cache_directory]
#
# This script enables a shadow cache for APT, which copies downloaded package 
# archives to a specified directory after each APT operation.
#
# If run without arguments, it will use the PEI_APT_SHADOW_CACHE_DIR environment 
# variable if set, or default to /apt-shadow-cache.
#
# Options:
#   custom_cache_directory    Specify a custom directory for the shadow cache.
#
# Examples:
#   ./enable-shadow-cache.sh
#   ./enable-shadow-cache.sh /my/custom/cache/dir
#
# Note: This script must be run with root privileges.

# if --help is used, print usage and exit
if [ "$1" == "--help" ]; then
    echo "Usage: ./enable-shadow-cache.sh [custom_cache_directory]"
    echo "This script enables a shadow cache for APT, which copies downloaded package archives to a specified directory after each APT operation."
    echo "If run without arguments, it will use the PEI_APT_SHADOW_CACHE_DIR environment variable if set, or default to /apt-shadow-cache."
    echo "Options:"
    echo "  custom_cache_directory    Specify a custom directory for the shadow cache."
    echo "Examples:"
    echo "  ./enable-shadow-cache.sh"
    echo "  ./enable-shadow-cache.sh /my/custom/cache/dir"
    exit 0
fi

# require root permission
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

# this script is used to enable shadow cache for apt
# which adds a dpkg post-invoke to copy archives to a directory

# check for the first argument, if set, set it to PEI_APT_SHADOW_CACHE_DIR
# otherwise, check if PEI_APT_SHADOW_CACHE_DIR is set as environment variable
# otherwise, set it to /apt-shadow-cache

if [ -n "$1" ]; then
    PEI_APT_SHADOW_CACHE_DIR="$1"
    echo "PEI_APT_SHADOW_CACHE_DIR is set to $PEI_APT_SHADOW_CACHE_DIR by argument"
elif [ -n "$PEI_APT_SHADOW_CACHE_DIR" ]; then
    echo "PEI_APT_SHADOW_CACHE_DIR is set to $PEI_APT_SHADOW_CACHE_DIR by environment variable"
else
    PEI_APT_SHADOW_CACHE_DIR="/apt-shadow-cache"
    echo "PEI_APT_SHADOW_CACHE_DIR is not set, setting it to default $PEI_APT_SHADOW_CACHE_DIR"
fi

# set permissions to 777
mkdir -p "$PEI_APT_SHADOW_CACHE_DIR"    # create the directory if it doesn't exist
chmod 777 "$PEI_APT_SHADOW_CACHE_DIR"
echo "APT shadow cache directory: $PEI_APT_SHADOW_CACHE_DIR"
# Get the ARCHIVE_DIR
ARCHIVE_DIR=$(grep -Po '(?<=^Dir::Cache::Archives\s\")[^\"]*' /etc/apt/apt.conf.d/* | tail -n1 | sed 's/^.*://')
if [ -z "$ARCHIVE_DIR" ]; then
    ARCHIVE_DIR='/var/cache/apt/archives'
fi

# add a dpkg post-invoke to copy archives to the directory
cat << EOF > /etc/apt/apt.conf.d/01-shadow-cache
DPkg::Post-Invoke {
    "cp -u $ARCHIVE_DIR/*.deb $PEI_APT_SHADOW_CACHE_DIR && chmod 777 $PEI_APT_SHADOW_CACHE_DIR/*.deb || true";
};
EOF

echo "APT shadow cache enabled. Archives will be copied to $PEI_APT_SHADOW_CACHE_DIR"

