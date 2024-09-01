#!/bin/bash

# install invoke ai directly without conda

# get env_name from argument, if not provided, use invoke-ai
# env_name=invoke-ai
env_name=$1
if [ -z "$env_name" ]; then
    env_name=invoke-ai
fi

# setup INVOKEAI_ROOT
invokeai_root=/soft/app/invokeai
export INVOKEAI_ROOT=$invokeai_root
mkdir -p $invokeai_root

# cd into INVOKEAI_ROOT
cd $invokeai_root

# install invoke ai with pip
echo "Installing InvokeAI with pip"
pip install InvokeAI --use-pep517 --extra-index-url  https://mirrors.aliyun.com/pytorch-wheels/cu121

# prevent conda from automatically activating base env
# conda config --set auto_activate_base false
# echo "Disabled conda auto activation, this is required to run InvokeAI in clean venv"

echo "then, use invokeai-web to start InvokeAI web server"
echo "NOTE: Set INVOKEAI_HOST to 0.0.0.0 to allow external access"
echo "NOTE: If your host is Windows, set CUDA_VISIBLE_DEVICES correctly before run!!"
