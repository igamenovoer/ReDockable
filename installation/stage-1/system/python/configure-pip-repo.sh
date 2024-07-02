#!/bin/sh

# configure pip to user tsinghua mirror

# if conda is not activated, activate it
if [ -z "$CONDA_DEFAULT_ENV" ]; then
    source /apps/miniconda3/bin/activate
fi

# configure pip
echo "Configuring pip to use Tsinghua mirror"
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple