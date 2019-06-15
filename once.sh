#!/usr/bin/env bash

yes-no() {
    local message
    message=${1}
    allowAbort=${2}

    read -p "$message " -n 1 -r -s

    loop=true
    while [ $loop == true ]
    do
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            printf "$REPLY" >&2
            RETURNVAR="$YES"
            return $YES
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            printf "$REPLY" >&2
            RETURNVAR="$NO"
            return $NO
        elif [[ ( $REPLY =~ ^[CcSs]$ ) && ( $allowAbort == "abort" ) ]]; then
            printf "$REPLY" >&2
            RETURNVAR="$SKIP"
            return $SKIP
        fi
        read -n 1 -r -s
    done
}

clear-line() {
    local columns
    columns=$(tput cols)
    printf "\r";
    for(( done=0; done<columns; done=done+1 )); do printf " "; done
    printf "\r";
}

SERVER_HOSTNAME=""
RETURNVAR=0
YES=1
NO=0
SKIP=2
INSTALLED=3

NGINX_INSTALLED=$NO
WEBMIN_INSTALLED=$NO
MARIADB_INSTALLED=$NO
LETSENCRYPT_INSTALLED=$NO
PAPERTRAIL_INSTALLED=$NO

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
console="simul@ted:~#"

cl_warn=$yellowbold
cl_errr=$redbold
cl_info=$blue
cl_high=$cyan
cl_cons=$purple
if [[ ${1} == "live" ]]; then
    simulated=0
else
    simulated=1
fi

interactive=$YES

if [[ $interactive == $YES ]]; then
    printf $cl_info"Create Webmin Custom Commands? "$clear
    yes-no "(y/n)"
    echo "";
fi
if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
    echo "H4sIAHk9BV0AA93VOW7sMAwA0D6nmF48AQGCFQtdimf/lGx50RbasYPgs4kHRvSGm+bzeT++fsG4h6giwpsIIhEhGqP2oEoOzY8ABvjg+D2N33kRFBFmLl8bLFJOWE6e6BeQyFadhKgE4r1GoIRmGQnDwvkzMYStYJ+Eheb9tDMXy2VVyQ/T6txG9IxcGeA/hpCdHd8sV5rTcM6k7fxNBPLVQcuSrYiuCD+D2L2RLw7StAOlJ5QL9xhSmxmhpeuPIKTNISockwASmPnieHWRGLUan5SISLp7V+RSKl2EJRV/NxMQNEMoxGv4J6yHgJwQNoEwSyKwI/50ukiUw/9bAghS4ow4l7KHIKedDgKaPxmCG6IVQkKdEzwI0nJiutUNE9qRWBq/hKUY8opeRMCEiEEhGYHzgmg6fQ2uEPudZ56nUyP2nTXgMkem5GMkquwR60wsFfsys/Y0mUgpzfozlTIgOiDSlotpPgRjJLc5J3JG6ky2QfAjcEIk31ZzRLfnu8jSDB0iekDulquEbUPo9uRJ5DhdQ8Rfrj4iI4SEt8aPV7JFIO1idCLWrQ0ZL2SLfBtHhMVz9f8UQdp6Mr74f4oc41cQ1sGAPYkgLP1pFuZJxLoTGO2PVo4PAReCXJYGvYjuW4nDq76fELmRNJ3lp9aXyTEpL7JfGIxvIeGgNAhyCGOivsfGCKZZ6SHE6yBNIsyRN+I/Qv4B1JtHLfASAAA=" | base64 -d | gunzip
fi
