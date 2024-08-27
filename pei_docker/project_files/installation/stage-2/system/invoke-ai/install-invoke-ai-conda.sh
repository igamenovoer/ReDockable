#!/bin/bash

# prepare conda env for invoke ai

# if conda is not activated, activate it
if [ -z "$CONDA_EXE" ]; then
    conda activate
fi

conda_root=$(conda info --base)
target_python_version=3.11

# create python 3.10 env
# get env_name from argument, if not provided, use invoke-ai
# env_name=invoke-ai
env_name=$1
if [ -z "$env_name" ]; then
    env_name=invoke-ai
fi

echo "Creating conda env $env_name"
conda create -n $env_name python=$target_python_version -y
source $conda_root/etc/profile.d/conda.sh

# Deactivate any active conda environments
echo "Deactivating any active conda environments"
while [[ "$CONDA_DEFAULT_ENV" != "" ]]; do
    conda deactivate
done

# activate the new env
echo "Activating $env_name"
conda activate $env_name

# setup INVOKEAI_ROOT
invokeai_root=/soft/app/invokeai
export INVOKEAI_ROOT=$invokeai_root
mkdir -p $invokeai_root

# cd into INVOKEAI_ROOT
cd $invokeai_root

# create venv and activate it
echo "Creating venv and activating it"
python -m venv .venv --prompt InvokeAI
source .venv/bin/activate

# install invoke ai with pip
echo "Installing InvokeAI with pip"
pip install InvokeAI --use-pep517 --extra-index-url  https://mirrors.aliyun.com/pytorch-wheels/cu121

echo "InvokeAI installed, deactivating venv and activating again"
# deactivate venv and activate again
deactivate
source .venv/bin/activate

echo "Done, use invokeai-web to start the web interface"
echo "If your host is Windows, set CUDA_VISIBLE_DEVICES correctly before run!!"
