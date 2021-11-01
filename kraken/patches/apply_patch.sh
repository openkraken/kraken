#!/bin/bash

PWD=$(pwd)
DART_VERSION=$(dart --version 2>&1 | awk '{print $4}')

vercomp () {
  if [[ $1 == $2 ]]
  then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
  do
    ver1[i]=0
  done
  for ((i=0; i<${#ver1[@]}; i++))
  do
    if [[ -z ${ver2[i]} ]]
    then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]}))
    then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]}))
    then
      return 2
    fi
  done
  return 0
}

testvercomp () {
  vercomp $1 $3
  case $? in
      0) op='=';;
      1) op='>';;
      2) op='<';;
  esac
  if [[ $op != $2 ]]
  then
      return 1
  else
      return 0
  fi
}

## Dart version > 2.14.0 means flutter 2.5.x
testvercomp $DART_VERSION ">" "2.14.0"
result=$?

if [ "$result" == 0 ]
then
  echo "Using flutter 2.5.x, applying patchs for flutter 2.5.x"
  ## Apply flutter 2.5.x patch
  for f in $PWD/patches/*.patch
  do
    patch --force -p1 < $f
  done
fi
