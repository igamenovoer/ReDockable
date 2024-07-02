#!/bin/sh

# if WITH_CUSTOM_APPS is false or not set, exit
if [ "$WITH_CUSTOM_APPS" != "true" ]; then
    exit
fi

export DEBIAN_FRONTEND=noninteractive

# nothing to do here, just exit
echo "Running build-time custom installation commands..."
echo "You can add your own installation commands to custom-install-apps.sh"