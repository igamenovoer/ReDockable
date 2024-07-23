#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# create a stage-1 env setup file in profile d, named env-stage-1.sh
# and add bash shebang
echo "#!/bin/bash" > /etc/profile.d/env-stage-1.sh

# source _setup-cuda.sh in env-stage-1.sh
echo "source $DIR/_setup-cuda.sh" >> /etc/profile.d/env-stage-1.sh

# add the following env variables to env-stage-1.sh
# INSTALL_DIR_CONTAINER_1
# PEI_HTTP_PROXY_1, PEI_HTTPS_PROXY_1, PEI_DOCKER_DIR
echo "export INSTALL_DIR_CONTAINER_1=$INSTALL_DIR_CONTAINER_1" >> /etc/profile.d/env-stage-1.sh
echo "export PEI_HTTP_PROXY_1=$PEI_HTTP_PROXY_1" >> /etc/profile.d/env-stage-1.sh
echo "export PEI_HTTPS_PROXY_1=$PEI_HTTPS_PROXY_1" >> /etc/profile.d/env-stage-1.sh
echo "export PEI_DOCKER_DIR=$PEI_DOCKER_DIR" >> /etc/profile.d/env-stage-1.sh

# # for every user, add $DIR/_setup-cuda.sh to their .bashrc, so that it is executed on every run
# # execute in user context with su
# for user in $(ls /home); do
#     echo "Adding $DIR/_setup-cuda.sh to /home/$user/.bashrc ..."
#     su - $user -c "echo 'source $DIR/_setup-cuda.sh' >> /home/$user/.bashrc"
# done

# # also do it for root
# echo "Adding $DIR/_setup-cuda.sh to /root/.bashrc ..."
# echo "source $DIR/_setup-cuda.sh" >> /root/.bashrc
