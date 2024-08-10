#!/bin/bash

# configure pip to use tuna or aliyun mirrors
# accept an argument to specify the mirror, can be tuna or aliyun

# check if we have an argument
if [ -z "$1" ]; then
    echo "Please specify a mirror name, tuna or aliyun"
    exit
fi

mirror_name=$1

# do we have pip command?
if ! command -v pip &> /dev/null
then
    echo "pip could not be found"
    exit
fi

# if mirror_name is tuna, set index_url=https://pypi.tuna.tsinghua.edu.cn/simple, trusted_host=pypi.tuna.tsinghua.edu.cn
if [ "$mirror_name" = "tuna" ]; then
    echo "Configuring pip to use Tsinghua mirror"
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
elif [ "$mirror_name" = "aliyun" ]; then
    echo "Configuring pip to use Aliyun mirror"
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
    pip config set global.trusted-host mirrors.aliyun.com
else
    echo "Unknown mirror name, exiting"
    exit
fi