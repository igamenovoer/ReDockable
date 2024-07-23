#!/bin/bash

# get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# echo "Executing $DIR/custom-on-user-login.sh ..."
SCRIPTFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
echo "Executing $SCRIPTFILE"

# source _setup-cuda.sh
# source "$DIR/_setup-cuda.sh"

DIR_GENERATED="$DIR/../generated"

if [ -f "$DIR_GENERATED/_custom-on-user-login.sh" ]; then
    source "$DIR_GENERATED/_custom-on-user-login.sh"
fi