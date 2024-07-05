#!/bin/bash

script_dir=$INSTALL_DIR_CONTAINER_1/internals

# run on-entry tasks
bash "$script_dir/on-entry.sh"

# first_run_signature_file=$PEI_DOCKER_DIR/stage-1-init-done

# # if first run signature file exists, skip the first run tasks
# # otherwise, run the first run tasks
# if [ -f $first_run_signature_file ]; then
#     echo "$first_run_signature_file found, skipping first run tasks"
# else
#     echo "$first_run_signature_file not found, running first run tasks ..."
#     bash $script_dir/on-first-run.sh
#     echo "Writing $first_run_signature_file"
#     echo "stage-1 is initialized" > $first_run_signature_file
# fi

# # execute on-every-run tasks
# bash $script_dir/on-every-run.sh

# check if ssh is installed, if yes, start the service
if [ -f /etc/ssh/sshd_config ]; then
    echo "Starting ssh service..."
    service ssh start
fi

# start shell
echo "Shell started."
export SHELL=/bin/bash
/bin/bash