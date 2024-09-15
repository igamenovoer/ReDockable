#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# check if INVOKEAI_AUTO_START is set to 1 or "true"
# if so, start InvokeAI using ./start-invokeai.sh

if [ -z "$INVOKEAI_AUTO_START" ]; then
    export INVOKEAI_AUTO_START=0
fi

if [ "$INVOKEAI_AUTO_START" -eq 1 ] || [ "$INVOKEAI_AUTO_START" = "true" ]; then
    echo "INVOKEAI_AUTO_START is enabled, starting InvokeAI on startup"
    target_script="$DIR/run-invoke-ai-multi-user.sh"

    bash $target_script
else
    echo "INVOKEAI_AUTO_START is disabled, InvokeAI will not start on startup"
    echo "use ./run-invoke-ai-multi-user.sh to start InvokeAI"
fi