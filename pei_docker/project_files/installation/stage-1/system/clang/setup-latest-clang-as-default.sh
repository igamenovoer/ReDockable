#!/bin/bash

# Get installed clang version
# Find all installed clang versions and get the latest one
CLANG_VERSION=$(ls /usr/bin/clang-* 2>/dev/null | grep -oP 'clang-\K[0-9]+' | sort -rn | head -n1)
if [ -z "$CLANG_VERSION" ]; then
    echo "No clang installation found"
    exit 1
fi
echo "Latest installed clang version: $CLANG_VERSION"

# Set clang as default compiler
update-alternatives --install /usr/bin/cc cc /usr/bin/clang-$CLANG_VERSION 50
update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-$CLANG_VERSION 50
