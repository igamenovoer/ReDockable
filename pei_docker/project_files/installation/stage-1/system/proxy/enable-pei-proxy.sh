#!/bin/bash

# Check and set HTTP proxy if PEI_HTTP_PROXY_1 exists
if [ ! -z "${PEI_HTTP_PROXY_1}" ]; then
  echo "Setting HTTP proxy 1: ${PEI_HTTP_PROXY_1}"
  export http_proxy="${PEI_HTTP_PROXY_1}"
  export HTTP_PROXY="${PEI_HTTP_PROXY_1}"
fi

# Check and set HTTPS proxy if PEI_HTTPS_PROXY_1 exists 
if [ ! -z "${PEI_HTTPS_PROXY_1}" ]; then
  echo "Setting HTTPS proxy 1: ${PEI_HTTPS_PROXY_1}"
  export https_proxy="${PEI_HTTPS_PROXY_1}"
  export HTTPS_PROXY="${PEI_HTTPS_PROXY_1}"
fi

# Check and set HTTP proxy if PEI_HTTP_PROXY_2 exists
if [ ! -z "${PEI_HTTP_PROXY_2}" ]; then
  echo "Setting HTTP proxy 2: ${PEI_HTTP_PROXY_2}"
  export http_proxy="${PEI_HTTP_PROXY_2}"
  export HTTP_PROXY="${PEI_HTTP_PROXY_2}"
fi

# Check and set HTTPS proxy if PEI_HTTPS_PROXY_2 exists 
if [ ! -z "${PEI_HTTPS_PROXY_2}" ]; then
  echo "Setting HTTPS proxy 2: ${PEI_HTTPS_PROXY_2}"
  export https_proxy="${PEI_HTTPS_PROXY_2}"
  export HTTPS_PROXY="${PEI_HTTPS_PROXY_2}"
fi
