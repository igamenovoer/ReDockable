#!/bin/bash

# run in entrypoint before ssh service starts

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/on-entry.sh ..."

first_run_signature_file=$PEI_DOCKER_DIR/stage-1-init-done

# if first run signature file exists, skip the first run tasks
# otherwise, run the first run tasks
if [ -f $first_run_signature_file ]; then
    echo "$first_run_signature_file found, skipping first run tasks"
else
    echo "$first_run_signature_file not found, running first run tasks ..."
    bash "$DIR/on-first-run.sh"
    echo "Writing $first_run_signature_file"
    echo "stage-1 is initialized" > $first_run_signature_file
fi

# execute on-every-run tasks
bash "$DIR/on-every-run.sh"