#!/bin/bash

# get the path of this file
SCRIPTFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
echo "Executing $SCRIPTFILE"