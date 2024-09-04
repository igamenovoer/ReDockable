#!/bin/bash

# startup script for InvokeAI intenteed to be run on every start

# stage-2 dir
stage2_dir=$PEI_STAGE_DIR_2

# look for a script stage2_dir/custom/start-invokeai.sh
if [ -f "$stage2_dir/custom/start-invokeai.sh" ]; then
    echo "Running custom start-invokeai.sh"
    bash $stage2_dir/custom/start-invokeai.sh
else
    echo "$stage2_dir/custom/start-invokeai.sh not found, skipping automatic startup"
fi
