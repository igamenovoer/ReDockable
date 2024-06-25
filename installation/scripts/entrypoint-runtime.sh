#!/bin/bash

# # if CHECK_AND_DO_INIT is true, run the on-first-run.sh for initialization
# if [ -n "$CHECK_AND_DO_INIT" ] && [ "$CHECK_AND_DO_INIT" = "true" ]; then
# fi
bash /installation/scripts/on-first-run.sh

# start default entrypoint
bash /installation/scripts/entrypoint-default.sh