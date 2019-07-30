#!/bin/bash

# Read a folder
# get *.conf

shopt -s extglob
configfolder="/home/recognizer/lempi/boxables/"
#configfile="/home/recognizer/lempi/boxables/paulwarren.ca.conf" # set the actual path name of your (DOS or Unix) config file


DATABASE=()
FILES=()
NGINX=
HOME=

#while IFS='= ' read -r lhs rhs; do
#  if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
#    rhs="${rhs%%\#*}"  # Del in line right comments
#    rhs="${rhs%%*( )}" # Del trailing spaces
#    rhs="${rhs%\"*}"   # Del opening string quotes
#    rhs="${rhs#\"*}"   # Del closing string quotes
#
#    if [[ $lhs == "home" ]]; then
#      HOME=$rhs
#    elif [[ $lhs == "files" ]]; then
#      FILES+=("$rhs")
#    elif [[ $lhs == "nginx" ]]; then
#      NGINX+=("$rhs")
#    elif [[ $lhs == "database" ]]; then
#      DATABASE+=("$rhs")
#    fi
#  fi
#done <$configfile.unix

clear-line() {
  local columns
  columns=$(tput cols)
  printf "\r"
  for ((done = 0; done < columns; done = done + 1)); do printf " "; done
  printf "\r"
}

initialize-backup-space() {
  # TODO Shuffle backup folders.
  # Delete 3
  # 2 -> 3, 1 -> 2, 0 -> 1, mkdir working;
  echo "INTIALIZING";
}


loop-sites() {
  for site in ${SITES[*]}; do
    DATABASE=()
    FILES=()
    NGINX=
    HOME=
    configfile=$site

    tr -d '\r' <$configfile >$configfile.unix_file
    while IFS='= ' read -r lhs rhs; do
      if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"  # Del in line right comments
        rhs="${rhs%%*( )}" # Del trailing spaces
        rhs="${rhs%\"*}"   # Del opening string quotes
        rhs="${rhs#\"*}"   # Del closing string quotes

        if [[ $lhs == "home" ]]; then
          HOME=$rhs
        elif [[ $lhs == "files" ]]; then
          FILES+=("$rhs")
        elif [[ $lhs == "nginx" ]]; then
          NGINX+=("$rhs")
        elif [[ $lhs == "database" ]]; then
          DATABASE+=("$rhs")
        fi
      fi
    done <$configfile.unix_file;

    # TODO mkdir folder within cur

    echo "FOR SITE: $configfile"
    echo "DATABASES:"
    # TODO FOR EACH database, run SQL to export it
    # copy to $backup/$database.sql
    printf '%s\n' "${DATABASE[@]}"
    echo "FILES:"
    # TODO FOR EACH file/folder, copy to backup folder
    # copy to $backup/home
    printf '%s\n' "${FILES[@]}"
    echo "NGINX:"
    # TODO For the nginx file, copy the file, then parse it for letsencrypt
    # copy to $backup/nginx.cfg
    # if SSL, copy cert and letsencrypt config
    printf '%s\n' "${NGINX[@]}"
    unlink $configfile.unix_file

    # TODO zip up site and plce in 0
    # TODO remove working backup folder
  done

  # TODO upload all files
}

parse-commandline() {
  for p in "$@"; do
    if [ $p == "full" ]; then
      BACKUPTYPE="full"
    fi
  done

  sites=$(find $configfolder -maxdepth 1 -type f)
  for site in $sites; do
    if [[ $site =~ .+\.conf$ ]]; then
      if [[ ${1} ]]; then
        if [[ $site == "$configfolder${1}.conf" ]]; then
          SITES+=($site)
        fi
      else
        SITES+=($site)
      fi
    fi
  done

  if [[ $SITES ]]; then
    if [[ ${1} ]]; then
      echo -e $cl_info"Running backup for just ${1}."$clear
    else
      echo -e $cl_info"Running backup for all"$clear
    fi
  else
    if [[ ${1} ]]; then
      echo -e $cl_errr"Could not find the site ${1} to backup."$clear
    else
      echo -e $cl_errr"Could not any sites to backup."$clear
    fi
  fi
}

# Global Variables
ABORT="abort"
RETURNVAR=
BACKUPTYPE="inc"
SITES=()
DATABASE=()
FILES=()
NGINX=
HOME=

whitebold="\e[1;30m"
redbold="\e[1;31m"
greenbold="\e[1;32m"
yellowbold="\e[1;33m"
bluebold="\e[1;34m"
purplebold="\e[1;35m"
cyanbold="\e[1;36m"
greybold="\e[1;37m"
white="\e[0;30m"
red="\e[0;31m"
green="\e[0;32m"
yellow="\e[0;33m"
blue="\e[0;34m"
purple="\e[0;35m"
cyan="\e[0;36m"
grey="\e[0;37m"
clear="\e[0m"

cl_warn=$yellowbold
cl_errr=$redbold
cl_info=$blue
cl_high=$cyan
cl_cons=$purple

console="simul@ted:~#"

parse-commandline "$@"
initialize-backup-space
loop-sites
clear-line


# echo $database
#printf '%s\n' "${SITES[@]}"
