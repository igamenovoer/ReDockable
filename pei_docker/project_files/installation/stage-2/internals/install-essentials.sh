#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# if WITH_ESSENTIAL_APPS is false or not set, exit
if [ "$WITH_ESSENTIAL_APPS" != "true" ]; then
  exit 0
fi