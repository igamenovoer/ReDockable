#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

CONDA_INSTALL_PATH="/apps/miniconda3"

# install miniconda3 to /apps/miniconda3
sh /installation/packages/Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_INSTALL_PATH

# make conda installation read/write for all users
echo "setting permissions for $CONDA_INSTALL_PATH ..."
chmod -R 777 $CONDA_INSTALL_PATH

echo "initializing conda for all users ..."
USER_LIST="root"

# add all user names to USER_LIST
for user in $(ls /home); do
  USER_LIST="$USER_LIST $user"
done

# for each user in USERS, initialize conda
for user in $USER_LIST; do
  su - $user -c "$CONDA_INSTALL_PATH/bin/conda init"

  # if user is root, set home_dir to /root, otherwise /home/$user
  if [ "$user" = "root" ]; then
    home_dir="/root"
  else
    home_dir="/home/$user"
  fi

  # replace .condarc with the pre-configured /installation/conda/conda-tsinghua.txt
  su - $user -c "cp /installation/conda/conda-tsinghua.txt $home_dir/.condarc"

  # call configure-pip-repo.sh
  su - $user -c "bash /installation/conda/configure-pip-repo.sh"
done

# initialize conda for all users
# for user in $(ls /home); do
#   su - $user -c "$CONDA_INSTALL_PATH/bin/conda init"
# done

# # also for root
# $CONDA_INSTALL_PATH/bin/conda init