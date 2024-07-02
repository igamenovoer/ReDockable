#!/bin/sh

# if WITH_CUSTOM_APPS is not true, exit
if [ "$WITH_CUSTOM_APPS" != "true" ]; then
  exit 0
fi

echo "In custom-install-apps.sh, add your custom installation commands here"