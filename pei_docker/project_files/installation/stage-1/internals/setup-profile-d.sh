#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/_setup-cuda.sh

# add the following env variables to env-stage-1.sh
# PEI_STAGE_DIR_1
# PEI_HTTP_PROXY_1, PEI_HTTPS_PROXY_1, PEI_DOCKER_DIR
echo "PEI_STAGE_DIR_1=$PEI_STAGE_DIR_1" >> /etc/environment
echo "PEI_HTTP_PROXY_1=$PEI_HTTP_PROXY_1" >> /etc/environment
echo "PEI_HTTPS_PROXY_1=$PEI_HTTPS_PROXY_1" >> /etc/environment
echo "PEI_DOCKER_DIR=$PEI_DOCKER_DIR" >> /etc/environment

# if CUDA_VISIBLE_DEVICES it not empty, add it to /etc/environment
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
