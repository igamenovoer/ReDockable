#!/bin/bash

# require root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Set proxy if PEI_PROXY_HTTP_PROXY_2 is defined and non-empty
if [ ! -z "${PEI_PROXY_HTTP_PROXY_2}" ]; then
    # Store original proxy settings
    OLD_HTTP_PROXY=$http_proxy
    OLD_HTTPS_PROXY=$https_proxy

    # Set new proxy settings
    export http_proxy=$PEI_PROXY_HTTP_PROXY_2
    export https_proxy=$PEI_PROXY_HTTP_PROXY_2
fi

# Install clang
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"