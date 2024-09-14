#!/bin/bash

# run invokeai on startup
# this script should be copied to stage-2/custom

# if INVOKEAI_AUTO_START does not exist, set it to 1
if [ -z "$INVOKEAI_AUTO_START" ]; then
    export INVOKEAI_AUTO_START=1
fi

# if INVOKEAI_AUTO_START is set to 0 or false, exit
if [ $INVOKEAI_AUTO_START -eq 0 ]; then
    echo "INVOKEAI_AUTO_START is set to 0, exit"
elif [ $INVOKEAI_AUTO_START == "false" ]; then
    echo "INVOKEAI_AUTO_START is set to false, exit"
else
    echo "INVOKEAI_AUTO_START is set to $INVOKEAI_AUTO_START, starting InvokeAI on startup"
    # echo "Starting InvokeAI on startup"

    # get directory of this script
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    # start invoke ai services for multiple users
    target_script="$DIR/../system/invoke-ai/run-invoke-ai-multi-user.sh"

    # run it
    bash $target_script
fi