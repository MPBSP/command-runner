#!/bin/bash
#title:         Directory Runner
#description:   Run command inside multiple directories
#author:        Madhuwantha Priashan Bandara
#created:       Dec 2021
#updated:       N/A
#version:       0.0.1
#usage:         ./runner.sh
#==============================================================================

REQUIRED_PKG="dialog"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG
fi


cmd=(dialog --separate-output --checklist "Select options:" 22 76 16)
dirs=(*/)

for NUM in ${!dirs[@]}; do
        options+=($NUM ${dirs[NUM]} off)
    done

choicedDirs=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
root=${PWD}


commands=("Other" "mvn clean install" "ls" "ls -al")

tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

dialog --backtitle "Command Selection" \
	--title "Select command to run" --clear \
        --radiolist "" 20 61 5 \
        "0" "Other" off \
        "1" "mvn clean install" ON \
        "2" "ls" off \
        "3" "ls -al" off 2> $tempfile

retval=$?

choicedCmd=`cat $tempfile`
clear

if [[ $choicedCmd -eq 0 ]]
then
  echo "other"
else
  for choice in $choicedDirs
    do
        current=${dirs[$choice]}
        cd $root/$current;eval ${commands[$choicedCmd]} &
    done
    wait
    exit
fi


#=================================================================================
