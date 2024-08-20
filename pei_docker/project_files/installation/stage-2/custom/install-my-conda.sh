#!/bin/bash

# prevent interactive prompts
export DEBIAN_FRONTEND=noninteractive

# PEI_STAGE_DIR_2 points to where the installation/stage-2 is inside container
STAGE_2_DIR_IN_CONTAINER=$PEI_STAGE_DIR_2
echo "STAGE_2_DIR_IN_CONTAINER: $STAGE_2_DIR_IN_CONTAINER"

# the installation directory of miniconda3
# first check for volume storage at /hard/volume/app, if not found, use /hard/image/app
if [ -d "/hard/volume/app" ]; then
  # volume storage takes precedence, note that it only exists in stage-2
  CONDA_INSTALL_DIR="/hard/volume/app/miniconda3"
else
  # otherwise, use the image storage
  CONDA_INSTALL_DIR="/hard/image/app/miniconda3"
fi

# already installed? skip
if [ -d $CONDA_INSTALL_DIR ]; then
    echo "miniconda3 is already installed in $CONDA_INSTALL_DIR, skipping ..."
    exit 0
fi

# download the miniconda3 installation file yourself, and put it in the tmp directory
# it will be copied to the container during the build process
CONDA_PACKAGE_NAME="Miniconda3-latest-Linux-x86_64.sh"

# are you in arm64 platform? If so, use the arm64 version of miniconda3
if [ "$(uname -m)" = "aarch64" ]; then
    CONDA_PACKAGE_NAME="Miniconda3-latest-Linux-aarch64.sh"
fi

# download from
CONDA_DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/$CONDA_PACKAGE_NAME"

# download to
CONDA_DOWNLOAD_DST="$STAGE_2_DIR_IN_CONTAINER/tmp/$CONDA_PACKAGE_NAME"

# if the file does not exist, wget it from tuna
if [ ! -f $CONDA_DOWNLOAD_DST ]; then
    echo "downloading miniconda3 installation file ..."
    wget -O $CONDA_DOWNLOAD_DST $CONDA_DOWNLOAD_URL --show-progress
fi

# install miniconda3 unattended
echo "installing miniconda3 to $CONDA_INSTALL_DIR ..."
bash $CONDA_DOWNLOAD_DST -b -p $CONDA_INSTALL_DIR

# make conda installation read/write for all users
echo "setting permissions for $CONDA_INSTALL_DIR ..."
chmod -R 777 $CONDA_INSTALL_DIR

echo "initializing conda for all users, including root ..."

# conda and pip mirror, for faster python package installation
# save the following content to a variable
read -r -d '' CONDA_TUNA << EOM
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  deepmodeling: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/
EOM

# tuna pip mirror
read -r -d '' PIP_TUNA << EOM
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple

[install]
trusted-host=pypi.tuna.tsinghua.edu.cn
EOM

# aliyun pypi mirror, use it if tuna is slow
read -r -d '' PIP_ALIYUN << EOM
[global]
index-url = https://mirrors.aliyun.com/pypi/simple

[install]
trusted-host=mirrors.aliyun.com
EOM

# add all user names to USER_LIST
USER_LIST="root"
for user in $(ls /home); do
    USER_LIST="$USER_LIST $user"
done

# remove duplicated user names, preventing install for root twice
USER_LIST=$(echo $USER_LIST | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
echo "conda config for users: $USER_LIST"

# for each user in USERS, initialize conda.
# remember to execute commands in the user context using su - $user -c
# otherwise the file will be owned by root
for user in $USER_LIST; do
    echo "initializing conda for $user ..."
    su - $user -c "$CONDA_INSTALL_DIR/bin/conda init"

    # if user is root, set home_dir to /root, otherwise /home/$user
    if [ "$user" = "root" ]; then
        home_dir="/root"
    else
        home_dir="/home/$user"
    fi

    # to use tuna mirror, replace the .condarc file with the pre-configured CONDA_TUNA
    echo "setting conda mirror for $user ..."    
    su - $user -c "echo \"$CONDA_TUNA\" >> $home_dir/.condarc"

    # to use pip mirror, create a .pip directory and write the PIP_TUNA to pip.conf
    echo "setting pip mirror for $user ..."
    su - $user -c "mkdir -p $home_dir/.pip"
    su - $user -c "echo \"$PIP_ALIYUN\" > $home_dir/.pip/pip.conf"
done