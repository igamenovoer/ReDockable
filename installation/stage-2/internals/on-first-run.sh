#!/bin/sh

echo "Running on-first-run.sh for initialization ..."

init_check_file_path=/stage-2-init-done

# check if the initialization has been done
# if yes, just return, otherwise, install the pre-configured apps
if [ -f $init_check_file_path ]; then
    echo "$init_check_file_path found, skipping apps installation"
    exit
fi

echo "$init_check_file_path not found, run the first run tasks ..."

export DEBIAN_FRONTEND=noninteractive

# do the first run tasks
bash $INSTALL_DIR_CONTAINER_2/custom/custom-first-run.sh

# write the init signature file to /apps
echo "Writing $init_check_file_path"
echo "stage-2 is initialized" > $init_check_file_path