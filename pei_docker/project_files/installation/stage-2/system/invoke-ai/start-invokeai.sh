#!/bin/bash

# run invokeai on startup
# this script should be copied to stage-2/custom

echo "Starting InvokeAI on startup"

# get directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# start invoke ai services for multiple users
target_script="$DIR/../system/invoke-ai/run-invoke-ai-multi-user.sh"

# run it
bash $target_script