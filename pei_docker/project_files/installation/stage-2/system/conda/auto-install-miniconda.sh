#!/bin/bash

# prevent interactive prompts
export DEBIAN_FRONTEND=noninteractive

# INSTALL_DIR_CONTAINER_2 points to where the installation/stage-2 is inside container
STAGE_2_DIR_IN_CONTAINER=$INSTALL_DIR_CONTAINER_2
echo "STAGE_2_DIR_IN_CONTAINER: $STAGE_2_DIR_IN_CONTAINER"

APP_IN_VOLUME="$PEI_PATH_HARD/$PEI_PREFIX_VOLUME/$PEI_PREFIX_APPS"
APP_IN_IMAGE="$PEI_PATH_HARD/$PEI_PREFIX_IMAGE/$PEI_PREFIX_APPS"

# if APP_IN_VOLUME exists, use it, otherwise use APP_IN_IMAGE
if [ -d $APP_IN_VOLUME ]; then
  echo "using $APP_IN_VOLUME ... to install miniconda3"
  CONDA_INSTALL_DIR=$APP_IN_VOLUME/miniconda3
else
  echo "using $APP_IN_IMAGE ... to install miniconda3"
  CONDA_INSTALL_DIR=$APP_IN_IMAGE/miniconda3
fi

# the installation directory of miniconda3
# will install to the in-image storage
CONDA_INSTALL_DIR="/hard/image/app/miniconda3"

# download the miniconda3 installation file yourself, and put it in the tmp directory
# it will be copied to the container during the build process
CONDA_PACKAGE_PATH="$STAGE_2_DIR_IN_CONTAINER/tmp/Miniconda3-latest-Linux-x86_64.sh"

# if the file does not exist, wget it from tuna
if [ ! -f $CONDA_PACKAGE_PATH ]; then
  echo "downloading miniconda3 installation file ..."
  wget -O $CONDA_PACKAGE_PATH https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
fi

# install miniconda3 unattended
echo "installing miniconda3 to $CONDA_INSTALL_DIR ..."
bash $CONDA_PACKAGE_PATH -b -p $CONDA_INSTALL_DIR

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

read -r -d '' PIP_TUNA << EOM
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple/

[install]
trusted-host=tuna.tsinghua.edu.cn
EOM

# add all user names to USER_LIST
USER_LIST="root"
for user in $(ls /home); do
    USER_LIST="$USER_LIST $user"
done

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
  su - $user -c "echo \"$CONDA_TUNA\" > $home_dir/.condarc"

  # to use pip mirror, create a .pip directory and write the PIP_TUNA to pip.conf
  echo "setting pip mirror for $user ..."
  su - $user -c "mkdir -p $home_dir/.pip"
  su - $user -c "echo \"$PIP_TUNA\" > $home_dir/.pip/pip.conf"
done