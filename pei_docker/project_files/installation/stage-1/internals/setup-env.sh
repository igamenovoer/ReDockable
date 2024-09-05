#!/bin/bash
# this script sets up all environment variables, as well as configuration files
# based on the environment variables

# set root password as ROOT_PASSWORD if it is not empty
if [ -n "$ROOT_PASSWORD" ]; then
  echo "Setting root password as $ROOT_PASSWORD"
  echo "root:$ROOT_PASSWORD" | chpasswd
fi

# if APT_USE_PROXY is true, set up proxy for apt
# the proxy is given in PEI_HTTP_PROXY_1 and PEI_HTTPS_PROXY_1
if [ "$APT_USE_PROXY" = "true" ]; then
  # if PEI_HTTP_PROXY_1 is not set, or PEI_HTTPS_PROXY_1 is not set
  # skip
  if [ -z "$PEI_HTTP_PROXY_1" ] || [ -z "$PEI_HTTPS_PROXY_1" ]; then
    echo "PEI_HTTP_PROXY_1 and PEI_HTTPS_PROXY_1 must be set if APT_USE_PROXY is true"
    echo "Skipping proxy setup for apt"    
  else
    echo "Setting up proxy for apt"
    echo "Acquire::http::Proxy \"$PEI_HTTP_PROXY_1\";" >> /etc/apt/apt.conf.d/proxy.conf
    echo "Acquire::https::Proxy \"$PEI_HTTPS_PROXY_1\";" >> /etc/apt/apt.conf.d/proxy.conf

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
    sed -i 's/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' $CURRENT_APT_SOURCE
    
  # if APT_SOURCE_FILE is 'aliyun', use aliyun mirrors
  # replace archive.ubuntu.com with mirrors.aliyun.com
  elif [ "$APT_SOURCE_FILE" = "aliyun" ]; then
    echo "Using aliyun mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' $CURRENT_APT_SOURCE
    sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g' $CURRENT_APT_SOURCE

  # if APT_SOURCE_FILE is '163', use 163 mirrors
  # replace archive.ubuntu.com with mirrors.163.com
  elif [ "$APT_SOURCE_FILE" = "163" ]; then
    echo "Using 163 mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/mirrors.163.com/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/mirrors.163.com/g' $CURRENT_APT_SOURCE
    sed -i 's/ports.ubuntu.com/mirrors.163.com/g' $CURRENT_APT_SOURCE

  # if APT_SOURCE_FILE is 'ustc', use ustc mirrors
  # replace archive.ubuntu.com with mirrors.ustc.edu.cn
  elif [ "$APT_SOURCE_FILE" = "ustc" ]; then
    echo "Using ustc mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' $CURRENT_APT_SOURCE
    sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g' $CURRENT_APT_SOURCE
  
  # if APT_SOURCE_FILE is 'cn', use cn mirrors
  # replace archive.ubuntu.com with cn.archive.ubuntu.com
  elif [ "$APT_SOURCE_FILE" = "cn" ]; then
    echo "Using cn mirrors"

    # replace normal sources and security sources
    sed -i 's/archive.ubuntu.com/cn.archive.ubuntu.com/g' $CURRENT_APT_SOURCE
    sed -i 's/security.ubuntu.com/cn.archive.ubuntu.com/g' $CURRENT_APT_SOURCE
    sed -i 's/ports.ubuntu.com/cn.ports.ubuntu.com/g' $CURRENT_APT_SOURCE
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
  echo "Acquire::Retries \"$APT_NUM_RETRY\";" >> /etc/apt/apt.conf.d/80-retries

  # set timeout to 20s
  echo "Acquire::http::Timeout \"5\";" >> /etc/apt/apt.conf.d/80-retries
  echo "Acquire::ftp::Timeout \"5\";" >> /etc/apt/apt.conf.d/80-retries
fi

# if ENABLE_GLOBAL_PROXY is true, set up proxy for all users
if [ "$ENABLE_GLOBAL_PROXY" = "true" ]; then
  # if PEI_HTTP_PROXY_1 is not set, or PEI_HTTPS_PROXY_1 is not set
  # skip
  if [ -z "$PEI_HTTP_PROXY_1" ] || [ -z "$PEI_HTTPS_PROXY_1" ]; then
    echo "PEI_HTTP_PROXY_1 and PEI_HTTPS_PROXY_1 must be set if ENABLE_PROXY_IN_BUILD is true"
    echo "Skipping proxy setup for build"
  else
    echo "Setting up proxy for build, write to /etc/environment"
    echo "http_proxy=$PEI_HTTP_PROXY_1" >> /etc/environment
    echo "https_proxy=$PEI_HTTPS_PROXY_1" >> /etc/environment
    echo "HTTP_PROXY=$PEI_HTTP_PROXY_1" >> /etc/environment
    echo "HTTPS_PROXY=$PEI_HTTPS_PROXY_1" >> /etc/environment
  fi
fi

# if PEI_BAKE_ENV_STAGE_1 is true, bake the environment variables to /etc/environment

if [ "$PEI_BAKE_ENV_STAGE_1" = "true" ]; then
  echo "Baking environment variables to /etc/environment"

  # get directory of this script
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

  # if DIR/../generated/_etc_environment.sh exists, append it to /etc/environment
  echo "Checking $DIR/../generated/_etc_environment.sh"
  if [ -f "$DIR/../generated/_etc_environment.sh" ]; then
    echo "Appending $DIR/../generated/_etc_environment.sh to /etc/environment"

    # add a new line first
    echo "" >> /etc/environment

    # append the file
    cat $DIR/../generated/_etc_environment.sh >> /etc/environment
  else
    echo "$DIR/../generated/_etc_environment.sh not found"
  fi
fi