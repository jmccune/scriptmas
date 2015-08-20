#!/bin/bash
# -- favorite.sh --
# Add a favorite to the file in ~/.favorites
#

FAVORITES_FILE=$HOME/.favorites
touch  $FAVORITES_FILE


# USAGE:
#-------------------------------
if [ "$#" -ne 1 ]; then
   echo " "
   echo "Usage: $0 [--list] [<FAVORITE_NAME>]"
   echo " --list will list all the favorites "
   echo " specifying a FAVORIT_NAME will cause the current directory to"
   echo " be added to the favorites file, which will make it possible to "
   echo " CD to one of the favorite spots."
   exit -1
fi

if [[ $1 = "--list" ]]; then
	echo "LISTING FAVORITES..."
	cat $FAVORITES_FILE
	exit -1
fi

if [[ $1 = "--"* ]]; then
	echo "--list is the only option."
	exit 1
fi

cwd=$(pwd);
echo "CREATING FAVORITE $1=$cwd"
echo "export $1=$cwd" >> $FAVORITES_FILE
source $FAVORITES_FILE