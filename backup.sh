#!/bin/bash

# https://docs.google.com/document/d/1m26y9BwS1KgvFZ56V61DoOASW6iJOkFLh7gV_qt0xvM/edit
# Read a folder
# get *.conf

shopt -s extglob
configfolder="/home/recognizer/lempi/boxables/"
googleFolder="1Y38Cm4f7d3N4Hf4cKvaxz1mdf2Y3QT-C"
#configfile="/home/recognizer/lempi/boxables/paulwarren.ca.conf" # set the actual path name of your (DOS or Unix) config file

# First, download and install gdrive
# Then setup the google folder to install to. Can't think of a good automated way to do it.
# Then setup papertrail settings.
# Setup the boxlog.py script.
# Run this once to initialize the google settings.

# leftovers
# nginx backup
# phpfpm backup
# letsencrypt backup
# other server specific things
# parse the nginx to gte the letsencrypt cert and config.



clear-line() {
  local columns
  columns=$(tput cols)
  printf "\r"
  for ((done = 0; done < columns; done = done + 1)); do printf " "; done
  printf "\r"
}

initialize-backup-space() {
  DIR_ROOTNS="root/backup"
  DIR_ROOT="/$DIR_ROOTNS"
  TEXT_TEMPOUT="$DIR_ROOT/temp/dropbox-output.txt"
  TEXT_MESSAGE="$DIR_ROOT/temp/message.txt"
  TEXT_FULLTRANS="$DIR_ROOT/temp/full-trans.txt"
  TEXT_FULLTRANS_GZ="$DIR_ROOT/temp/full-trans.txt.gz"
  TEXT_SUMMARY="$DIR_ROOT/temp/summary.txt"
  TEXT_ERRORS="$DIR_ROOT/temp/errors.txt"
  TEXT_UPERRORS="$DIR_ROOT/temp/upload-errors.txt"

  cd $DIR_ROOT
  # 1. Delete backup/archive/3. Move 2->3, 1->2, working->1.
  mkdir $DIR_ROOT 2>/dev/null
  mkdir $DIR_ROOT/archive 2>/dev/null
  rm -r $DIR_ROOT/archive/3 2>/dev/null
  mv $DIR_ROOT/archive/2 $DIR_ROOT/archive/3 2>/dev/null
  mv $DIR_ROOT/archive/1 $DIR_ROOT/archive/2 2>/dev/null
  mv $DIR_ROOT/archive/0 $DIR_ROOT/archive/1 2>/dev/null
  mkdir $DIR_ROOT/archive/0 2>/dev/null
  mkdir $DIR_ROOT/mysql 2>/dev/null
  mkdir $DIR_ROOT/temp 2>/dev/null

  touch $TEXT_MESSAGE
  touch $TEXT_FULLTRANS
  touch $TEXT_SUMMARY
  touch $TEXT_ERRORS
  touch $TEXT_UPERRORS

  cat /dev/null >$TEXT_MESSAGE
  cat /dev/null >$TEXT_SUMMARY
  cat /dev/null >$TEXT_FULLTRANS
  cat /dev/null >$TEXT_ERRORS
  cat /dev/null >$TEXT_UPERRORS
}

prepare-archive() {
  site=$1
  workingfolder=$DIR_ROOT/archive/0
  if [ $BACKUPTYPE == "full" ]; then
    DATE=$(date +%Y.%m)
    ARCHIVE="$workingfolder/$site-$DATE.tar"
    #    log "qwerqwer" "another"
  else
    DATE=$(date +%Y.%m.%d)
    ARCHIVE="$workingfolder/$site-$DATE-inc.tar"
    #    log "test" "another"
  fi

  # create the archive.
  tar cvf $ARCHIVE -C / --files-from /dev/null
}

backup-files() {
  for file in ${FILES[*]}; do
    DIR=$HOME$file
    if [ $BACKUPTYPE == "full" ]; then
      tar rvf $ARCHIVE -C $HOME $file --transform 's,^,files/,' 2>>$TEXT_ERRORS 1>>$TEXT_FULLTRANS
    else
      cd $HOME
      find $file -mtime $MONTH_DATE -type f -print | tar rvf $ARCHIVE -T - --transform 's,^,files/,' 2>>$TEXT_ERRORS 1>>$TEXT_FULLTRANS
    fi
  done

  for database in ${DATABASES[*]}; do
    $MYSQL_DUMP --force --opt --skip-lock-tables --databases $database >$DIR_ROOT/mysql/$database.sql 2>>$TEXT_ERRORS
  done
  if [ ${#DATABASES[*]} -ne '0' ]; then
    tar rvf $ARCHIVE -C $DIR_ROOT mysql/ 2>>$TEXT_ERRORS 1>>$TEXT_FULLTRANS
  fi

  gzip $ARCHIVE
  ARCHIVE="$ARCHIVE.gz"

  cd /root
  gdrive upload $ARCHIVE -p $googleFolder
}

log() {
  echo -e "${@}"
  message=$(echo -e "${@}")
  python /home/recognizer/lempi/boxlog.py "$message"
}

loop-sites() {
  # https://docs.google.com/document/d/1Qyvaf0ayaCPk-SpxuR71h_SmSx6lhUOlqDITByvDgwE/edit#heading=h.o6trhi8pb4l
  for site in ${SITES[*]}; do
    DATABASES=()
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
          DATABASES+=("$rhs")
        fi
      fi
    done <$configfile.unix_file

    site=$(echo $configfile | sed -e 's/.*\(\\\|\/\)\(.*\)\.conf$/\2/g')
    prepare-archive $site
    backup-files

    echo "FOR SITE: $configfile"
    #    echo "DATABASES:"
    #    # TODO FOR EACH database, run SQL to export it
    #    # copy to $backup/$database.sql
    #    printf '%s\n' "${DATABASE[@]}"
    #    echo "FILES:"
    #    # TODO FOR EACH file/folder, copy to backup folder
    #    # copy to $backup/home
    #    printf '%s\n' "${FILES[@]}"
    echo "NGINX:"
    # TODO For the nginx file, copy the file, then parse it for letsencrypt
    # copy to $backup/nginx.cfg
    # if SSL, copy cert and letsencrypt config
    # https://druss.co/2019/03/migrate-letsencrypt-certificates-certbot-to-new-server/
    printf '%s\n' "${NGINX[@]}"
    unlink $configfile.unix_file
  done
  log $cl_high"Backup complete."$clear
}

parse-commandline() {
  sitespecific=
  for p in "$@"; do
    if [ $p == "full" ]; then
      BACKUPTYPE="full"
    elif [ $p == "inc" ]; then
      BACKUPTYPE="inc"
    else
      sitespecific=${1}
    fi
  done

  sites=$(find $configfolder -maxdepth 1 -type f)
  for site in $sites; do
    if [[ $site =~ .+\.conf$ ]]; then
      if [[ $sitespecific ]]; then
        if [[ $site == "$configfolder${1}.conf" ]]; then
          SITES+=($site)
        fi
      else
        SITES+=($site)
      fi
    fi
  done

  if [[ $SITES ]]; then
    if [[ $sitespecific ]]; then
      log $cl_info"Running backup for just $sitespecific."$clear
    else
      log $cl_info"Running backup for all"$clear
    fi
  else
    if [[ $sitespecific ]]; then
      log $cl_errr"Could not find the site $sitespecific to backup."$clear
    else
      log $cl_errr"Could not any sites to backup."$clear
    fi
  fi
}

cleanup() {
  rm $DIR_ROOT/temp -r
  rm $DIR_ROOT/mysql -r
  log $
}

# Global Variables
ABORT="abort"
RETURNVAR=
BACKUPTYPE="inc"
SITES=()
DATABASES=()
FILES=()
NGINX=
HOME=
ARCHIVE=
MONTH_DATE=-$(date +%d)
MYSQL_DUMP="/usr/bin/mysqldump"

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
cleanup

# echo $database
#printf '%s\n' "${SITES[@]}"
