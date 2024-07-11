#!/bin/bash

# configure pip to user tsinghua mirror

# if conda is not activated, skip
if [ -z "$CONDA_DEFAULT_ENV" ]; then
    echo "Conda is not activated, skipping pip configuration for user $USER"
    exit
fi

# configure pip
echo "Configuring pip to use Tsinghua mirror"
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple