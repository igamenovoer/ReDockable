#!/bin/bash

#!/bin/bash

# Usage: ./enable-external-cache.sh [custom_cache_directory]
#
# This script enables an external cache for APT, which stores downloaded package 
# archives in a specified directory. This allows for package caching across 
# container rebuilds or system reinstalls.
#
# If run without arguments, it will use the PEI_APT_CACHE_DIR environment 
# variable if set, or default to /apt-ext-store.
#
# Options:
#   custom_cache_directory    Specify a custom directory for the external cache.
#
# Examples:
#   ./enable-external-cache.sh
#   ./enable-external-cache.sh /my/custom/cache/dir
#
# Note: This script must be run with root privileges.

# if --help is used, print usage and exit
if [ "$1" == "--help" ]; then
    echo "Usage: ./enable-external-cache.sh [custom_cache_directory]"
    echo "This script enables an external cache for APT, which stores downloaded package archives in a specified directory."
    echo "If run without arguments, it will use the PEI_APT_CACHE_DIR environment variable if set, or default to /apt-ext-store."
    echo "Options:"
    echo "  custom_cache_directory    Specify a custom directory for the external cache."
    echo "Examples:"
    echo "  ./enable-external-cache.sh"
    echo "  ./enable-external-cache.sh /my/custom/cache/dir"
    exit 0
fi


# require root permission
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

# do we have an argument?
if [ -n "$1" ]; then
    PEI_APT_CACHE_DIR="$1"
    echo "PEI_APT_CACHE_DIR is set to $PEI_APT_CACHE_DIR"
elif [ -n "$PEI_APT_CACHE_DIR" ]; then
    echo "PEI_APT_CACHE_DIR is set to $PEI_APT_CACHE_DIR by environment variable"
else
    echo "PEI_APT_CACHE_DIR is not set, setting it to /apt-ext-store"
    PEI_APT_CACHE_DIR="/apt-ext-store"
fi

# Check if PEI_APT_CACHE_DIR environment variable is set
if [ -n "$PEI_APT_CACHE_DIR" ]; then

    # # look for a file in /etc/apt/apt.conf.d/docker-clean
    # # if exists, move it to /etc/apt/apt.conf.d/docker-clean.bak
    # echo "disable docker-clean so that apt cache can be reused"
    # if [ -f /etc/apt/apt.conf.d/docker-clean ]; then
    #     mv /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/docker-clean.bak
    # fi

    # Create the directory if it doesn't exist
    mkdir -p "$PEI_APT_CACHE_DIR"

    # set permissions to 777
    chmod 777 "$PEI_APT_CACHE_DIR"
    echo "APT persistent cache directory: $PEI_APT_CACHE_DIR"

    # Create a new APT configuration file, copy archives to PEI_APT_CACHE_DIR and set their permissions to 777
    cat << EOF > /etc/apt/apt.conf.d/01-external-cache
// Enable persistent cache
Binary::apt::APT::Keep-Downloaded-Packages "true";
APT::Keep-Downloaded-Packages "true";
Dir::Cache::Archives "$PEI_APT_CACHE_DIR";

EOF

    echo "APT persistent cache enabled. Archives will be copied to $PEI_APT_CACHE_DIR"
else
    echo "PEI_APT_CACHE_DIR environment variable is not set. Persistent cache not enabled."
fi

