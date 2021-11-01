#!/bin/bash

echo "Type your path name: "

KRAKEN_HOME=$PWD

read filename

echo "Generating $filename.path..."

git add lib
git diff --staged --relative ./lib  > $KRAKEN_HOME/patches/$filename.patch
