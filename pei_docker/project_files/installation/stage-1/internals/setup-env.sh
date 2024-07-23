#!/bin/bash
# this script sets up all environment variables, as well as configuration files
# based on the environment variables

# set root password as ROOT_PASSWORD if it is not empty
if [ -n "$ROOT_PASSWORD" ]; then
  echo "Setting root password as $ROOT_PASSWORD"
  echo "root:$ROOT_PASSWORD" | chpasswd
fi

# if APT_USE_PROXY is true, set up proxy for apt
# the proxy is given in PEI_HTTP_PROXY and PEI_HTTPS_PROXY
if [ "$APT_USE_PROXY" = "true" ]; then
  # if PEI_HTTP_PROXY is not set, or PEI_HTTPS_PROXY is not set
  # skip
  if [ -z "$PEI_HTTP_PROXY" ] || [ -z "$PEI_HTTPS_PROXY" ]; then
    echo "PEI_HTTP_PROXY and PEI_HTTPS_PROXY must be set if APT_USE_PROXY is true"
    echo "Skipping proxy setup for apt"    
  else
    echo "Setting up proxy for apt"
    echo "Acquire::http::Proxy \"$PEI_HTTP_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf
    echo "Acquire::https::Proxy \"$PEI_HTTPS_PROXY\";" >> /etc/apt/apt.conf.d/proxy.conf

    echo "/etc/apt/apt.conf.d/proxy.conf:"
    cat /etc/apt/apt.conf.d/proxy.conf
  fi
fi

# apt source file, it can be /etc/apt/sources.list or /etc/apt/sources.list.d/ubuntu.sources
# see which file exists, check /etc/apt/sources.list.d/ubuntu.sources first
CURRENT_APT_SOURCE=/etc/apt/sources.list
if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
  echo "/etc/apt/sources.list.d/ubuntu.sources exists"
  CURRENT_APT_SOURCE="/etc/apt/sources.list.d/ubuntu.sources"
fi

# if you want to use proxy in shell, just use ENV in your dockerfile

# if APT_SOURCE_FILE is set, use it to replace /etc/apt/sources.list
if [ -n "$APT_SOURCE_FILE" ]; then
  echo "Using $APT_SOURCE_FILE as /etc/apt/sources.list"

  # backup the original sources.list
  cp "$CURRENT_APT_SOURCE" "$CURRENT_APT_SOURCE.bak"

  # check for special values
  # if APT_SOURCE_FILE is 'tuna', use tuna mirrors
  # replace archive.ubuntu.com with mirrors.tuna.tsinghua.edu.cn
  if [ "$APT_SOURCE_FILE" = "tuna" ]; then
    echo "Using tuna mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' $CURRENT_APT_SOURCE
    
  # if APT_SOURCE_FILE is 'aliyun', use aliyun mirrors
  # replace archive.ubuntu.com with mirrors.aliyun.com
  elif [ "$APT_SOURCE_FILE" = "aliyun" ]; then
    echo "Using aliyun mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' $CURRENT_APT_SOURCE

  # if APT_SOURCE_FILE is '163', use 163 mirrors
  # replace archive.ubuntu.com with mirrors.163.com
  elif [ "$APT_SOURCE_FILE" = "163" ]; then
    echo "Using 163 mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/mirrors.163.com/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/mirrors.163.com/g' $CURRENT_APT_SOURCE

  # if APT_SOURCE_FILE is 'ustc', use ustc mirrors
  # replace archive.ubuntu.com with mirrors.ustc.edu.cn
  elif [ "$APT_SOURCE_FILE" = "ustc" ]; then
    echo "Using ustc mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' $CURRENT_APT_SOURCE
  
  # if APT_SOURCE_FILE is 'cn', use cn mirrors
  # replace archive.ubuntu.com with cn.archive.ubuntu.com
  elif [ "$APT_SOURCE_FILE" = "cn" ]; then
    echo "Using cn mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/cn.archive.ubuntu.com/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/cn.archive.ubuntu.com/g' $CURRENT_APT_SOURCE
  else
    # copy the new sources.list
    cp $APT_SOURCE_FILE $CURRENT_APT_SOURCE
  fi

  # display contents of /etc/apt/sources.list
  cat $CURRENT_APT_SOURCE
fi

# if APT_NUM_RETRY is set, set the number of retries for apt
if [ -n "$APT_NUM_RETRY" ]; then
  echo "Setting APT::Acquire::Retries \"$APT_NUM_RETRY\";"
  echo "APT::Acquire::Retries \"$APT_NUM_RETRY\";" >> /etc/apt/apt.conf.d/80-retries
fi