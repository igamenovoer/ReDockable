#!/bin/bash

# stage 2 entrypoint, part of the content is from stage 1 entrypoint

script_dir_1=$PEI_STAGE_DIR_1/internals
script_dir_2=$PEI_STAGE_DIR_2/internals

# run on-entry tasks for stage 1
bash $script_dir_1/on-entry.sh

# run on-entry tasks for stage 2
bash $script_dir_2/on-entry.sh

# # do first run tasks
# bash $script_dir_1/on-first-run.sh

# # create links
# bash $script_dir_2/create-links.sh

# # do first run tasks in stage 2
# bash $script_dir_2/on-first-run.sh

# check if ssh is installed, if yes, start the service
if [ -f /etc/ssh/sshd_config ]; then
    echo "Starting ssh service..."
    service ssh start
fi

# start shell
echo "Shell started."
export SHELL=/bin/bash
/bin/bash