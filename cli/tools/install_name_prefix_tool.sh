#!/bin/bash

# install_name_prefix_tool
#
# Copyright (c) 2013 Martin Szulecki <martin.szulecki@gmail.com>
#
# Licensed under the GNU General Public License Version 2
#
# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more profile.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
# USA

if [ $# -lt 3 ]
then
	echo "Usage: ${0##*/} <DIR|FILE> <OLD> <NEW>"
	echo "Changes the library prefix from OLD to NEW for each <DIR>/*.dylib or executable <FILE>."
	exit 1
fi

TARGETS=$1
PREFIX=$2
NEWPREFIX=$3

if [[ -d $TARGETS ]]; then
	TARGETS=$TARGETS/*.dylib
elif [[ -f $TARGETS ]]; then
	TARGETS="$TARGETS"
else
    echo "Error: \"$TARGETS\" does not exist."
    exit 1
fi

INSTALL_NAME_TOOL_BIN=$(which install_name_tool)
OTOOL_BIN=$(which otool)
GREP_BIN=$(which egrep)

for lib in $TARGETS;
do
	echo "Modifing library \"$lib\"..."
	lib_basename=$(basename $lib)
	for entry in $($OTOOL_BIN -L $lib | $GREP_BIN -o "$PREFIX/([^[:space:]]*)");
	do
		entry_basename=$(basename $entry)
		entry_target="$NEWPREFIX/$entry_basename"

		ID_ADD=""
		if [ "$lib_basename" = "$entry_basename" ];
		then
			ID_ADD="-id $entry_basename"
		fi

		echo "Changing prefix \"$entry\" to \"$entry_target\"..."
		$INSTALL_NAME_TOOL_BIN -change $entry $entry_target $ID_ADD $lib
	done
done
