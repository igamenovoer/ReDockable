#!/bin/bash

# if WITH_CUSTOM_APPS is not true, exit
if [ "$WITH_CUSTOM_APPS" != "true" ]; then
  exit 0
fi

echo "Stage 2 custom installation ..."
echo "In custom-install-apps.sh, add your custom installation commands here"
