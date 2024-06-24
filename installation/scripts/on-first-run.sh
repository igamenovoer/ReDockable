#!/bin/sh

# if CHECK_AND_DO_INIT is present and set to false, skip the initialization
if [ -n "$CHECK_AND_DO_INIT" ] && [ "$CHECK_AND_DO_INIT" = "false" ]; then
    echo "CHECK_AND_DO_INIT is set to false, skipping the initialization"
    exit
fi

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
sh /installation/helpers/install-miniconda.sh

# write the config.yaml file to /apps
echo "Writing config.yaml to /apps"
cat <<EOF > /apps/config.yaml