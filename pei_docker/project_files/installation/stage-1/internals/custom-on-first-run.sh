#!/bin/bash

# get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/custom-on-first-run.sh ..."

DIR_GENERATED="$DIR/../generated"

if [ -f "$DIR_GENERATED/_custom-on-first-run.sh" ]; then
    echo "Found custom on-first-run script, executing ..."
    bash "$DIR_GENERATED/_custom-on-first-run.sh"
fi