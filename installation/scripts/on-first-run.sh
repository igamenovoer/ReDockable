#!/bin/sh

echo "Running on-first-run.sh for initialization ..."

# check if there is a file named config.yaml in /apps
# if yes, just return, otherwise, install the pre-configured apps
if [ -f /apps/config.yaml ]; then
    echo "config.yaml found in /apps, skipping apps installation"
    exit
fi

echo "config.yaml not found in /apps, installing pre-configured apps"

export DEBIAN_FRONTEND=noninteractive

# install conda
echo "Installing Miniconda"
sh /installation/conda/install-miniconda.sh

# write the config.yaml file to /apps
echo "Writing config.yaml to /apps"
cat <<EOF > /apps/config.yaml