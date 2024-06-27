#!/bin/sh

echo "Running on-first-run.sh for initialization ..."

init_check_file_path=$X_PATH_SOFT_BASE/init-done.yaml

# check if the initialization has been done
# if yes, just return, otherwise, install the pre-configured apps
if [ -f $init_check_file_path ]; then
    echo "$init_check_file_path found, skipping apps installation"
    exit
fi

echo "$init_check_file_path not found, installing pre-configured apps"

export DEBIAN_FRONTEND=noninteractive

echo "Running custom-first-run.sh ..."
bash /installation/custom-scripts/custom-first-run.sh

# install conda
# echo "Installing Miniconda"
# sh /installation/conda/install-miniconda.sh

# write the config.yaml file to /apps
echo "Writing $init_check_file_path"
cat <<EOF > $init_check_file_path