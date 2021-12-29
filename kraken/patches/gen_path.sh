## Shell scripts can easily generate patch files from git staged changes in lib/ directory.

#!/bin/bash

echo "Type your path name: "

KRAKEN_HOME=$PWD

read filename

echo "Generating patch file at $KRAKEN_HOME/patches/$filename.patch ..."

## Add add files to staged changes.
git add lib
git diff --staged --relative ./lib  > $KRAKEN_HOME/patches/$filename.patch
