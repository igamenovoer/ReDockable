#!/bin/bash

script_dir=$INSTALL_DIR_CONTAINER_1/internals

# do first run tasks
bash $script_dir/on-first-run.sh

# check if ssh is installed, if yes, start the service
if [ -f /etc/ssh/sshd_config ]; then
    echo "Starting ssh service..."
    service ssh start
fi

# start shell
echo "Shell started."
export SHELL=/bin/bash
/bin/bash