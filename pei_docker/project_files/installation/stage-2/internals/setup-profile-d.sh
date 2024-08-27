#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/_setup-cuda.sh

# add the following env variables to env-stage-2.sh using echo
# PEI_STAGE_DIR_2
# PEI_PREFIX_DATA, PEI_PREFIX_APPS, PEI_PREFIX_WORKSPACE, PEI_PREFIX_VOLUME, PEI_PREFIX_IMAGE
# PEI_PATH_HARD, PEI_PATH_SOFT, PEI_SOFT_APPS, PEI_SOFT_DATA, PEI_SOFT_WORKSPACE, PEI_SOFT_VOLUME, PEI_SOFT_IMAGE

echo "PEI_HTTP_PROXY_2=$PEI_HTTP_PROXY_2" >> /etc/environment
echo "PEI_HTTPS_PROXY_2=$PEI_HTTPS_PROXY_2" >> /etc/environment
echo "PEI_STAGE_DIR_2=$PEI_STAGE_DIR_2" >> /etc/environment
echo "PEI_PREFIX_DATA=$PEI_PREFIX_DATA" >> /etc/environment
echo "PEI_PREFIX_APPS=$PEI_PREFIX_APPS" >> /etc/environment
echo "PEI_PREFIX_WORKSPACE=$PEI_PREFIX_WORKSPACE" >> /etc/environment
echo "PEI_PREFIX_VOLUME=$PEI_PREFIX_VOLUME" >> /etc/environment
echo "PEI_PREFIX_IMAGE=$PEI_PREFIX_IMAGE" >> /etc/environment
echo "PEI_PATH_HARD=$PEI_PATH_HARD" >> /etc/environment
echo "PEI_PATH_SOFT=$PEI_PATH_SOFT" >> /etc/environment
echo "PEI_SOFT_APPS=$PEI_SOFT_APPS" >> /etc/environment
echo "PEI_SOFT_DATA=$PEI_SOFT_DATA" >> /etc/environment
echo "PEI_SOFT_WORKSPACE=$PEI_SOFT_WORKSPACE" >> /etc/environment

# if CUDA_VISIBLE_DEVICES exists and it not empty, add it to /etc/environment
# FIXME: this is not working
if [ -n "$CUDA_VISIBLE_DEVICES" ]; then
    echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES" >> /etc/environment
fi

# # for every user, add $DIR/_setup-cuda.sh to their .bashrc, so that it is executed on every run
# # execute in user context with su
# for user in $(ls /home); do
#     echo "Adding $DIR/_setup-cuda.sh to /home/$user/.bashrc ..."
#     su - $user -c "echo 'source $DIR/_setup-cuda.sh' >> /home/$user/.bashrc"
# done

# # also do it for root
# echo "Adding $DIR/_setup-cuda.sh to /root/.bashrc ..."
# echo "source $DIR/_setup-cuda.sh" >> /root/.bashrc
