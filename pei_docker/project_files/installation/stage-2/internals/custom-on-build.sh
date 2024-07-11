#!/bin/bash

# called by Dockerfile by the end of the build process

# get the path of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Executing $DIR/custom-on-build.sh ..."

DIR_GENERATED="$DIR/../generated"

# if the file exists, execute it
if [ -f "$DIR_GENERATED/_custom-on-build.sh" ]; then
    echo "Found custom on-build script, executing ..."
    bash "$DIR_GENERATED/_custom-on-build.sh"
fi