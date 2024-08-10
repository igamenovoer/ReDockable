#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/install-miniconda.sh ..."

CONDA_INSTALL_DIR="$PEI_SOFT_APPS/miniconda3"

# check if the cpu is arm64, if yes, use tmp/Miniconda3-latest-Linux-aarch64.sh
# else use tmp/Miniconda3-latest-Linux-x86_64.sh
if [ "$(uname -m)" = "aarch64" ]; then
  CONDA_PACKAGE_PATH="$PEI_STAGE_DIR_2/tmp/Miniconda3-latest-Linux-aarch64.sh"
else
  CONDA_PACKAGE_PATH="$PEI_STAGE_DIR_2/tmp/Miniconda3-latest-Linux-x86_64.sh"
fi

CONDA_SCRIPT_DIR="$PEI_STAGE_DIR_2/system/conda"
INSTALL_FOR_ROOT="false"

# install miniconda3 to /app/miniconda3
bash $CONDA_PACKAGE_PATH -b -p $CONDA_INSTALL_DIR

# make conda installation read/write for all users
echo "setting permissions for $CONDA_INSTALL_DIR ..."
chmod -R 777 $CONDA_INSTALL_DIR

echo "initializing conda for all users ..."

if [ "$INSTALL_FOR_ROOT" = "true" ]; then
  USER_LIST="root"
else
  USER_LIST=""
fi

# add all user names to USER_LIST
for user in $(ls /home); do
  USER_LIST="$USER_LIST $user"
done

# for each user in USERS, initialize conda
for user in $USER_LIST; do
  su - $user -c "$CONDA_INSTALL_DIR/bin/conda init"

  # if user is root, set home_dir to /root, otherwise /home/$user
  if [ "$user" = "root" ]; then
    home_dir="/root"
  else
    home_dir="/home/$user"
  fi

  # replace .condarc with the pre-configured /installation/conda/conda-tsinghua.txt
  su - $user -c "cp $CONDA_SCRIPT_DIR/conda-tsinghua.txt $home_dir/.condarc"

  # activate conda and call configure-pip-repo.sh
  su - $user -c "source $CONDA_INSTALL_DIR/bin/activate && bash $CONDA_SCRIPT_DIR/configure-pip-repo.sh aliyun"

done