#!/bin/bash

# run invoke ai
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# start invoke ai services for multiple users
# target_script="$DIR/../system/invoke-ai/run-invoke-ai-multi-user.sh"
target_script="$DIR/run-invoke-ai-multi-user.sh"

# run it
bash $target_script