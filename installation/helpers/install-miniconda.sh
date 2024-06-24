#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

CONDA_INSTALL_PATH="/apps/miniconda3"
# install miniconda3 to /apps/miniconda3
sh /installation/packages/Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_INSTALL_PATH

# initialize conda for all users
for user in $(ls /home); do
  su - $user -c "$CONDA_INSTALL_PATH/bin/conda init"
done

# also for root
$CONDA_INSTALL_PATH/bin/conda init