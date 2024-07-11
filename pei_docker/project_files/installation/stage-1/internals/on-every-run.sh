#!/bin/bash

# get current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/on-every-run.sh ..."

# nothing to do, just call custom on-first-run script
bash "$DIR/custom-on-every-run.sh"