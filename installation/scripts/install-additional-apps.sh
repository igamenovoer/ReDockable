#!/bin/sh

# if WITH_ADDITIONAL_APPS is false or not set, exit
if [ "$WITH_ADDITIONAL_APPS" != "true" ]; then
    exit
fi

export DEBIAN_FRONTEND=noninteractive

# nothing to do here, just exit
echo "No additional apps to install, please add your own commands to install-additional-apps.sh"