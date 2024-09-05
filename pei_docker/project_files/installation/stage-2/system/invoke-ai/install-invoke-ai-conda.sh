#!/bin/bash

# prepare conda env for invoke ai

# do we have INVOKEAI_ROOT set?
if [ -z "$INVOKEAI_ROOT" ]; then
    invokeai_root=/soft/app/invokeai
    echo "INVOKEAI_ROOT not set, setting it to $invokeai_root"
    export INVOKEAI_ROOT=$invokeai_root
else
    echo "INVOKEAI_ROOT already set to $INVOKEAI_ROOT, use it"
    invokeai_root=$INVOKEAI_ROOT
fi

# do we already have InvokeAI installed?
if [ -f "$invokeai_root/.venv/bin/invokeai-web" ]; then
    echo "InvokeAI already installed in $invokeai_root/.venv, just use it"
    exit 0
fi

# ok, make sure invokeai_root exist
mkdir -p $invokeai_root

# do we have conda command?
conda_root=/soft/app/miniconda3
echo "Assuming conda is installed in $conda_root"
if [ ! -d "$conda_root" ]; then
    echo "Conda not found in $conda_root, exit"
    exit 1
fi
target_python_version=3.11
source $conda_root/etc/profile.d/conda.sh

# make sure conda will NOT be activated automatically in the future
conda config --set auto_activate_base false

# create python env
# get env_name from argument, if not provided, use invoke-ai
# env_name=invoke-ai
env_name=$1
if [ -z "$env_name" ]; then
    env_name=invoke-ai
fi

# this env already exists?
if conda env list | grep -q $env_name; then
    echo "Conda env $env_name already exists, just use it"
else
    echo "Creating conda env $env_name with python $target_python_version"
    conda create -n $env_name python=$target_python_version -y
fi

# Deactivate any active conda environments
echo "Deactivating any active conda environments"
while [[ "$CONDA_DEFAULT_ENV" != "" ]]; do
    conda deactivate
done

# activate the new env
echo "Activating $env_name"
conda activate $env_name

# push current dir
pushd $(pwd)

# cd into INVOKEAI_ROOT
cd $invokeai_root

# create venv and activate it
echo "Creating venv and activating it"
python -m venv .venv --prompt InvokeAI
source .venv/bin/activate

# install invoke ai with pip
echo "Installing InvokeAI with pip"
pip install InvokeAI --use-pep517 --extra-index-url  https://mirrors.aliyun.com/pytorch-wheels/cu121

# deactivate conda and venv
conda deactivate
deactivate

echo "InvokeAI installed"
# deactivate venv

# source .venv/bin/activate

# prevent conda from automatically activating base env
# conda config --set auto_activate_base false
# echo "Disabled conda auto activation, this is required to run InvokeAI in clean venv"

echo "use 'source $invokeai_root/.venv/bin/activate' to activate InvokeAI venv"
echo "then, use $invokeai_root/invokeai-web.sh to start InvokeAI web server"
echo "NOTE: Set INVOKEAI_HOST to 0.0.0.0 to allow external access"
echo "NOTE: If your host is Windows, set CUDA_VISIBLE_DEVICES correctly before run!!"

# pop back to original dir
popd