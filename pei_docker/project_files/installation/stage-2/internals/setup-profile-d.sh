#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# create a stage-2 env setup file in profile d, named env-stage-2.sh
# and add bash shebang
echo "#!/bin/bash" > /etc/profile.d/env-stage-2.sh

# source _setup-cuda.sh in env-stage-2.sh
echo "source $DIR/_setup-cuda.sh" >> /etc/profile.d/env-stage-2.sh

# add the following env variables to env-stage-2.sh using echo
# INSTALL_DIR_CONTAINER_2
# PEI_PREFIX_DATA, PEI_PREFIX_APPS, PEI_PREFIX_WORKSPACE, PEI_PREFIX_VOLUME, PEI_PREFIX_IMAGE
# PEI_PATH_HARD, PEI_PATH_SOFT, PEI_SOFT_APPS, PEI_SOFT_DATA, PEI_SOFT_WORKSPACE, PEI_SOFT_VOLUME, PEI_SOFT_IMAGE

echo "export PEI_HTTP_PROXY_2=$PEI_HTTP_PROXY_2" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_HTTPS_PROXY_2=$PEI_HTTPS_PROXY_2" >> /etc/profile.d/env-stage-2.sh
echo "export INSTALL_DIR_CONTAINER_2=$INSTALL_DIR_CONTAINER_2" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_PREFIX_DATA=$PEI_PREFIX_DATA" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_PREFIX_APPS=$PEI_PREFIX_APPS" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_PREFIX_WORKSPACE=$PEI_PREFIX_WORKSPACE" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_PREFIX_VOLUME=$PEI_PREFIX_VOLUME" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_PREFIX_IMAGE=$PEI_PREFIX_IMAGE" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_PATH_HARD=$PEI_PATH_HARD" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_PATH_SOFT=$PEI_PATH_SOFT" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_SOFT_APPS=$PEI_SOFT_APPS" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_SOFT_DATA=$PEI_SOFT_DATA" >> /etc/profile.d/env-stage-2.sh
echo "export PEI_SOFT_WORKSPACE=$PEI_SOFT_WORKSPACE" >> /etc/profile.d/env-stage-2.sh

# # for every user, add $DIR/_setup-cuda.sh to their .bashrc, so that it is executed on every run
# # execute in user context with su
# for user in $(ls /home); do
#     echo "Adding $DIR/_setup-cuda.sh to /home/$user/.bashrc ..."
#     su - $user -c "echo 'source $DIR/_setup-cuda.sh' >> /home/$user/.bashrc"
# done

# # also do it for root
# echo "Adding $DIR/_setup-cuda.sh to /root/.bashrc ..."
# echo "source $DIR/_setup-cuda.sh" >> /root/.bashrc
