#!/bin/bash

PWD=$(pwd)

for f in $PWD/patches/*.patch
do
  patch -p1 < $f
done
