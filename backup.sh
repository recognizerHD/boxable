#!/bin/bash

# Read a folder
# get *.conf

shopt -s extglob
configfile="/root/boxables/paulwarren.ca.conf" # set the actual path name of your (DOS or Unix) config file
tr -d '\r' < $configfile > $configfile.unix
while IFS='= ' read -r lhs rhs
do
    if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
    echo "$rhs .=. $lhs"
        rhs="${rhs%%\#*}"    # Del in line right comments
        rhs="${rhs%%*( )}"   # Del trailing spaces
        rhs="${rhs%\"*}"     # Del opening string quotes
        rhs="${rhs#\"*}"     # Del closing string quotes
        declare $lhs="$rhs"

        echo $database
    fi
done < $configfile.unix