#!/bin/bash

progress-bar() {
    local columns
    local space_available
    local space_reserved
    local percentage
    local fit_to_screen
    local duration

    space_reserved=6 # reserved width for the percentage value
    columns=$(tput cols)
    duration=100
    percentage=${1}
    space_available=$(( columns-space_reserved ))
    precision=1000
    if (( duration < space_available )); then
        fit_to_screen=$(( 1*precision ));
    else
        fit_to_screen=$(( duration*precision/space_available*precision/precision ));
    fi

    percent_columns=$(( percentage*precision/fit_to_screen ))
    duration_columns=$(( duration*precision/fit_to_screen ))
    alt=$((duration*100/space_available*100/100))
    #already_done() { for ((done=0; done<(percentage / fit_to_screen) ; done=done+1 )); do printf "▇"; done }
    already_done() { for ((done=0; done<percent_columns; done=done+1 )); do printf "#"; done }
    remaining() { for (( remain=percent_columns; remain<duration_columns; remain=remain+1 )); do printf " "; done }
    percentagenum() { printf "| %s%%" $percentage; }
    clean_line() { printf "\r"; }

    printf "$cl_info"
    already_done; remaining; percentagenum;
    printf "$clear\n";
}

clear-line() {
    local columns
    columns=$(tput cols)
    printf "\r";
    for(( done=0; done<columns; done=done+1 )); do printf " "; done
    printf "\r";
}

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

show-intro() {
    # echo $(cat logo.txt | gzip | base64 -w0)
    printf $cl_warn
    echo "H4sIAHk9BV0AA93VOW7sMAwA0D6nmF48AQGCFQtdimf/lGx50RbasYPgs4kHRvSGm+bzeT++fsG4h6giwpsIIhEhGqP2oEoOzY8ABvjg+D2N33kRFBFmLl8bLFJOWE6e6BeQyFadhKgE4r1GoIRmGQnDwvkzMYStYJ+Eheb9tDMXy2VVyQ/T6txG9IxcGeA/hpCdHd8sV5rTcM6k7fxNBPLVQcuSrYiuCD+D2L2RLw7StAOlJ5QL9xhSmxmhpeuPIKTNISockwASmPnieHWRGLUan5SISLp7V+RSKl2EJRV/NxMQNEMoxGv4J6yHgJwQNoEwSyKwI/50ukiUw/9bAghS4ow4l7KHIKedDgKaPxmCG6IVQkKdEzwI0nJiutUNE9qRWBq/hKUY8opeRMCEiEEhGYHzgmg6fQ2uEPudZ56nUyP2nTXgMkem5GMkquwR60wsFfsys/Y0mUgpzfozlTIgOiDSlotpPgRjJLc5J3JG6ky2QfAjcEIk31ZzRLfnu8jSDB0iekDulquEbUPo9uRJ5DhdQ8Rfrj4iI4SEt8aPV7JFIO1idCLWrQ0ZL2SLfBtHhMVz9f8UQdp6Mr74f4oc41cQ1sGAPYkgLP1pFuZJxLoTGO2PVo4PAReCXJYGvYjuW4nDq76fELmRNJ3lp9aXyTEpL7JfGIxvIeGgNAhyCGOivsfGCKZZ6SHE6yBNIsyRN+I/Qv4B1JtHLfASAAA=" | base64 -d | gunzip
    printf $clear;

    if [[ $simulated == 1 ]]; then
        echo -e $cl_high"Running in simulated mode. No changes will actually be done."
        echo -e $cl_high"To run for real, run this file again like this: \"./lempi.sh live\"."$clear
    else
        echo -e $cl_warn"Running in production. This will make changes to your system in:"
        printf  $cl_warn"     >             5   "$clear
        sleep 1;
        printf $cl_warn"\r     >"$redbold"---"$cl_warn"          4   "$clear
        sleep 1;
        printf $cl_warn"\r     >   "$redbold"---"$cl_warn"       3   "$clear
        sleep 1;
        printf $cl_warn"\r     >      "$redbold"---"$cl_warn"    2   "$clear
        sleep 1;
        printf $cl_warn"\r     >         "$redbold"---"$cl_warn" 1   "$clear
        sleep 1;
        clear-line
    fi


    echo -e $yellowbold"Minion Factory Server Setup";
    echo "";
    echo -e $cl_info"Before you begin, you will need: "
    echo -e $yellowbold"Hostname$cl_info - a fully qualified domain name."
    echo -e $yellowbold"Papertrail hostname and port$cl_info - Used for logging."
    echo -e $yellowbold"Username for default server$cl_info - this is where phpMyAdmin will sit."
    echo -e $yellowbold"Username$cl_info - for your future login. You'll also supply a password when prompted.";
#    echo -e $yellowbold"Username$cl_info - for your future login. You'll also supply a password when prompted.";

    echo "";

    echo -e $cl_info"First, some small packages needed for the installation and other tasks will be installed.";
    echo -e $cl_info"You will be prompted to create a user and be set up to log in with that account instead of root.";
    echo -e $cl_info"Next, various small packages used for backups and other background processes will be installed.";
    echo -e $cl_info"Then you will be asked to install the following packages:\e[0m ";
    echo -e $cl_info"       nginx-extras: "$cl_high"Latest";
    echo -e $cl_info"            MariaDB: "$cl_high"10.1";
    echo -e $cl_info"            PHP-FPM: "$cl_high"7.3";
    echo -e $cl_info"             Webmin: "$cl_high"Latest";
    echo -e $cl_info"Letsencrypt/Certbot: "$cl_high"Latest"$clear;

    printf $cl_info"Install with defaults? Choosing yes will install all packages without prompting where possible. "$clear
    yes-no "(y/n)"
    if [[ $RETURNVAR == $YES ]]; then
        interactive=$NO
    else
        interactive=$YES
    fi
    echo ""
}

setup-vim() {
    # Setup Vim how I like it.
    if [[ $simulated == 1 ]]; then
        echo -e $cl_cons"$console cat > /etc/vim/vimrc.local << EOF .... EOF ";
        return;
    fi

    cat > /etc/vim/vimrc.local << EOF
set tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab
set ruler
set showmode
set esckeys
set nocompatible
set backspace=indent,eol,start
EOF
}

setup-hostname() {
    hostname_value=$(hostname)
    SERVER_HOSTNAME=$hostname_value
    echo -e $cl_info"The hostname is used for the default nginx config. Make sure it's fully qualified domain name."
    printf $cl_info"Change Hostname from $cl_high$hostname_value$cl_info? "$clear
    yes-no "(y/n)"
    echo "";
    if [[ $RETURNVAR == $NO ]]; then
        return;
    fi

    hostname_loop=true
    while [ $hostname_loop == true ]
    do
        read -p "Enter a new hostname: " hostname_value
        if [[ $hostname_value =~ ^[a-z_][\.A-Za-z0-9_-]*[$]?$ ]]; then
            printf $cl_info"Continue with $cl_high$hostname_value$cl_info? "$clear
            yes-no "(y/n/c)" "abort"
            echo "";
            if [[ $RETURNVAR == $YES ]]; then
                hostname_loop=false
            elif [[ $RETURNVAR == $SKIP ]]; then
                return;
            fi
        else
            clear-line;
            printf $cl_errr"Hostname is not valid. Try again? "$clear
            yes-no "(y/n)"
            if [[ $RETURNVAR == $NO ]]; then
                echo "";
                return;
            fi
        fi
    done

    if [[ $simulated == 1 ]]; then
        echo -e $cl_cons"$console hostname $hostname_value ";
    else
        hostname $hostname_value
        SERVER_HOSTNAME=$hostname_value
    fi
    echo -e $cl_info"Hostname is now:$cl_high $hostname_value"$clear
}

setup-various() {
    if [[ $simulated == 1 ]]; then
        echo -e $cl_cons"$console install -y ncftp unzip putty-tools python-mysqldb python-apt rsyslog sharutils curl nodejs bsd-mailx "
    else
        echo ""
        apt install -y -q ncftp unzip putty-tools python-mysqldb python-apt rsyslog sharutils curl nodejs bsd-mailx
    fi
}

setup-papertrail() {
    printf $cl_info"Setup Papertrail? "$clear
    yes-no "(y/n)"
    echo ""
    if [[ $RETURNVAR == $NO ]]; then
        return;
    fi

    if [[ $simulated == 1 ]]; then
        echo -e $cl_cons"$console cat > /etc/log_files.yml << EOF .... EOF ";
        echo -e $cl_cons"$console dpkg -i remote-syslog2_0.20_amd64.deb << EOF .... EOF ";
        echo -e $cl_cons"$console cat > /etc/log_files.yml << EOF .... EOF ";
        return
    fi


    domainname_loop=true
    while [ $domainname_loop == true ]
    do
        read -p "Enter a papertrail host: " papertrail_hostname_value
        if [[ $papertrail_hostname_value =~ ^[a-z_][\.A-Za-z0-9_-]*[$]?$ ]]; then
            printf $cl_info"Continue with host $cl_high$papertrail_hostname_value$cl_info? "$clear
            yes-no "(y/n/c)" "abort"
            echo "";
            if [[ $RETURNVAR == $YES ]]; then
                domainname_loop=false
            elif [[ $RETURNVAR == $SKIP ]]; then
                return;
            fi
        else
            clear-line;
            printf $cl_errr"Hostname "$cl_high$papertrail_hostname_value$cl_errr" is not valid. Try again? "$clear
            yes-no "(y/n)"
            if [[ $RETURNVAR == $NO ]]; then
                echo "";
                return;
            fi
        fi
    done

    port_loop=true
    while [ $port_loop == true ]
    do
        read -p "Enter a papertrail port: " papertrail_port_value
        if [[ $papertrail_port_value =~ ^[0-9]*[$]?$ ]]; then
            printf $cl_info"Continue with port $cl_high$papertrail_port_value$cl_info? "$clear
            yes-no "(y/n/c)" "abort"
            echo "";
            if [[ $RETURNVAR == $YES ]]; then
                port_loop=false
            elif [[ $RETURNVAR == $SKIP ]]; then
                return;
            fi
        else
            clear-line;
            printf $cl_errr"Port "$cl_high$papertrail_port_value$cl_errr" is not valid. Try again? "$clear
            yes-no "(y/n)"
            if [[ $RETURNVAR == $NO ]]; then
                echo "";
                return;
            fi
        fi
    done

    touch /var/log/nginx/access.log
    touch /var/log/nginx/error.log
    touch /var/log/mysql/mariadb-slow.log
    touch /var/log/php7.3-fpm.log
    touch /var/log/letsencrypt/letsencrypt.log

    cat > /etc/rsyslog.d/30-papertrail.conf << EOF
local7.err      /var/log/nginx/error.log
local7.info     /var/log/nginx/access.log
local6.warning  /var/log/mysql/mariadb-slow.log
local5.*        /var/log/php7.3-fpm.log
local4.*        /var/log/letsencrypt/letsencrypt.log
EOF


    # TODO Add this
    # "log_format main '[31m\$remote_addr[0m - \$remote_user [\$time_local] [35m\$status[0m [44m \$host [0m [34m\"\$request\"[0m \$body_bytes_sent \"\$http_referer\" \"\$http_user_agent\" \"\$http_x_forwarded_for\"';"
    # access_log syslog:server=$papertrail_hostname_value:$papertrail_port_value,facility=local7,tag=nginx_access,severity=info main;
    # error_log syslog:server=$papertrail_hostname_value:$papertrail_port_value,facility=local7,tag=nginx_errors;

    remote_syslog2_installed=$(remote_syslog -V 2> /dev/null)
    if [[ $remote_syslog2_installed != 'remote_syslog: command not found' ]]; then
        wget https://github.com/papertrail/remote_syslog2/releases/download/v0.20/remote-syslog2_0.20_i386.deb
        wget https://github.com/papertrail/remote_syslog2/releases/download/v0.20/remote-syslog2_0.20_amd64.deb
        dpkg -i remote-syslog2_0.20_i386.deb
        dpkg -i remote-syslog2_0.20_amd64.deb
    fi

    cat > /etc/log_files.yml << EOF
files:
#  - locallog.txt
 - /var/log/nginx/access.log
 - /var/log/nginx/error.log
 - /var/log/mysql/mariadb-slow.log
 - /var/log/php7.3-fpm.log
 - /var/log/letsencrypt/letsencrypt.log
destination:
  host: $papertrail_hostname_value
  port: $papertrail_port_value
  protocol: tls
exclude_patterns:
  - don\'t log on me
EOF
    remote_syslog &
    PAPERTRAIL_INSTALLED=$INSTALLED
}

create-user() {
    local username
    printf $cl_info"Setup a new user? "$clear
    yes-no "(y/n)"
    echo "";
    if [[ $RETURNVAR == $NO ]]; then
        return;
    fi

    username_loop=true
    while [ $username_loop == true ]
    do
        read -p "Enter a new username: " username
        if [[ $username =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
            printf $cl_info"Continue with $cl_high$username$cl_info? "$clear
            yes-no "(y/n/c)" "abort"
            echo "";
            if [[ $RETURNVAR == $YES ]]; then
                username_loop=false
            elif [[ $RETURNVAR == $SKIP ]]; then
                return;
            fi
        else
            clear-line;
            printf $cl_errr"Username is not valid. Try again? "$clear
            yes-no "(y/n)"
            if [[ $RETURNVAR == $NO ]]; then
                echo "";
                return;
            fi
        fi
    done

    echo ""
    echo -e $cl_info"Your username is:$cl_high $username"$clear

    if [[ $simulated == 1 ]]; then
        echo -e $cl_cons"$console useradd --user-group --shell /bin/bash --group sudo --create-home $username"
        echo -e "$console passwd $username"
        echo -e "$console sudo -u $username ssh-keygen -t rsa"
        echo -e "$console sudo -u $username cp /home/$username/.ssh/id_rsa.pub /home/$username/.ssh/authorized_keys2"
        echo -e "$console sudo -u $username puttygen /home/$username/.ssh/id_rsa -o /home/$username/.ssh/id_rsa.ppk"
        echo -e "$console sudo -u $username cat /home/$username/.ssh/id_rsa.ppk"
        echo -e "$console sed -i -e 's/PermitRootLogin yes/PermitRootLogin without-password/g' /etc/ssh/sshd_config" $clear
    else
        useradd --user-group --shell /bin/bash --group sudo --create-home $username
        # Set the password for the new account.
        passwd $username

        echo -e $cl_info "Creating RSA Key" $clear
        sudo -u $username ssh-keygen -t rsa
        sudo -u $username cp /home/$username/.ssh/id_rsa.pub /home/$username/.ssh/authorized_keys2
        sudo -u $username puttygen /home/$username/.ssh/id_rsa -o /home/$username/.ssh/id_rsa.ppk

        printf $cl_info"Display private key for copying to your local computer? "$clear
        yes-no "(y/n)"
        echo "";
        if [[ $RETURNVAR == $YES ]]; then
            cat /home/$username/.ssh/id_rsa.ppk
        else
            echo $yellow"If you want to view it later, view the file at /home/$username/.ssh/id_rsa.ppk"$clear
        fi

        if [[ $interactive == $YES ]]; then
            printf $cl_info"Require root login to use private key and not password? "$clear
            yes-no "(y/n)"
            echo "";
        fi
        if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
            # make sure root cannot log in anymore.
            sed -i -e 's/PermitRootLogin yes/PermitRootLogin without-password/g' /etc/ssh/sshd_config
        fi
    fi
    echo ""
}

create-hosting-user() {
    local username
    echo -e $cl_info"A hosting user is used for the default website. You will not be logging in with this user."
    printf $cl_info"Setup a hosting user? "$clear
    yes-no "(y/n)"
    echo "";
    if [[ $RETURNVAR == $NO ]]; then
        return;
    fi

    username_loop=true
    while [ $username_loop == true ]
    do
        read -p "Enter a new hosting username: " username
        if [[ $username =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
            printf $cl_info"Continue with $cl_high$username$cl_info? "$clear
            yes-no "(y/n/c)" "abort"
            echo "";
            if [[ $RETURNVAR == $YES ]]; then
                username_loop=false
            elif [[ $RETURNVAR == $SKIP ]]; then
                return;
            fi
        else
            clear-line;
            printf $cl_errr"Username is not valid. Try again? "$clear
            yes-no "(y/n)"
            if [[ $RETURNVAR == $NO ]]; then
                echo "";
                return;
            fi
        fi
    done

    if [[ $simulated == 1 ]]; then
        echo -e $cl_cons"$console useradd --user-group --shell /dev/null --create-home $username"
    else
        useradd --user-group --shell /dev/null --create-home $username
        sudo -u $username mkdir /home/$username/bin
        sudo -u $username mkdir /home/$username/phpmyadmin
        cd /home/$username
        sudo -u $username -H git clone --depth=1 --branch=STABLE git://github.com/phpmyadmin/phpmyadmin.git
        cd /home/$username/phpmyadmin
        sudo -u $username -H composer install

        secret=$(head /dev/urandom | tr -dc 'A-Za-z0-9!#%&()*+,-./:;<=>?@[\]^_`{|}~' | head -c 30)
        cat > /home/$username/phpmyadmin/config.inc.php << EOF
<?php

/* Servers configuration */
\$i = 0;

/* Server: localhost [1] */
\$i++;
\$cfg['Servers'][\$i]['verbose'] = '';
\$cfg['Servers'][\$i]['host'] = 'localhost';
\$cfg['Servers'][\$i]['port'] = '';
\$cfg['Servers'][\$i]['socket'] = '';
\$cfg['Servers'][\$i]['auth_type'] = 'cookie';
\$cfg['Servers'][\$i]['user'] = '';
\$cfg['Servers'][\$i]['password'] = '';

/* End of servers configuration */

\$cfg['blowfish_secret'] = '$secret';
\$cfg['DefaultLang'] = 'en';
\$cfg['ServerDefault'] = 1;
\$cfg['UploadDir'] = '';
\$cfg['SaveDir'] = '';
EOF
        chmod -r /home/$username/phpmyadmin/setup

        cat > /home/$username/bin/update-phpmyadmin.sh << EOF
#!/bin/bash
cd /home/$username/phpmyadmin
git pull -q origin STABLE
composer install
EOF
        chown $username.$username /home/$username/bin/update-phpmyadmin.sh
        chmod +x /home/$username/bin/update-phpmyadmin.sh
        ( sudo -u $username crontab -l 2>/dev/null; echo "00 05 * * 1 /home/$username/bin/update-phpmyadmin.sh" ) | sudo -u $username crontab

        sudo -u $username mkdir /home/$username/public_html
        sudo -u $username mkdir /home/$username/tmp
        chmod 750 /home/$username/tmp

        cat > /etc/php/7.3/fpm/pool.d/$username.conf << EOF
[$username]
user = $username
group = $username
listen = /var/run/php/php7.3-fpm.$username.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
php_admin_value[upload_tmp_dir] = /home/$username/tmp
php_admin_value[session.save_path] = /home/$username/tmp
EOF
        service php7.3-fpm restart

        cat > /etc/nginx/sites-available/$SERVER_HOSTNAME.conf << EOF
server {
    server_name $SERVER_HOSTNAME;
    root /home/$username/public_html;
    index index.html index.htm index.php;

    include /etc/nginx/snippets/location-standard.conf;

    # phpMyAdmin setup for /db
    location /db {
        alias /home/$username/phpmyadmin/;
        try_files /test.php?a=4 \$uri \$uri/ /index.php?\$args;
    }

    location ~ ^/db/(.+\.php)$ {
        alias /home/$username/phpmyadmin/\$1;

        include /etc/nginx/snippets/fastcgi-params.conf;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /home/$username/phpmyadmin/\$1;

        fastcgi_pass unix:/var/run/php/php7.3-fpm.$username.sock;

        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 16k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
    }

    # cache.appcache, your document html and data
    location ~* ^/db/(.+\.(?:manifest|appcache|html?|xml|json))$ {
        alias /home/$username/phpmyadmin/\$1;
        add_header Cache-Control "max-age=0";
    }

    # Feed
    location ~* ^/db/(.+\.(?:rss|atom))$ {
        alias /home/$username/phpmyadmin/\$1;
        add_header Cache-Control "max-age=3600";
    }

    # Media: images, icons, video, audio, HTC
    location ~* ^/db/(.+\.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|mp4|ogg|ogv|webm|htc))$ {
        alias /home/$username/phpmyadmin/\$1;
        access_log off;
        add_header Cache-Control "max-age=2592000";
    }

    # Media: svgz files are already compressed.
    location ~* ^/db/(.+\.svgz)$ {
        alias /home/$username/phpmyadmin/\$1;
        access_log off;
        gzip off;
        add_header Cache-Control "max-age=2592000";
    }

    # CSS and Javascript
    location ~* ^/db/(.+\.(?:css|js))$ {
        alias /home/$username/phpmyadmin/\$1;
        add_header Cache-Control "max-age=31536000";
        access_log off;
    }

    include /etc/nginx/snippets/x-ua-compatible.conf;
    include /etc/nginx/snippets/expires.conf;
    # include /etc/nginx/snippets/protect-system-files.conf;
    include /etc/nginx/snippets/ssl-stapling.conf;

    location ~ \.php$ {
        include /etc/nginx/snippets/fastcgi-php.conf;

        fastcgi_pass unix:/var/run/php/php7.3-fpm.$username.sock;

        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 16k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
    }

    listen [::]:80 default_server ipv6only=on;
    listen 80 default;
}
EOF
        ln -s /etc/nginx/sites-available/$SERVER_HOSTNAME.conf /etc/nginx/sites-enabled/$SERVER_HOSTNAME.conf

        rm /etc/nginx/sites-available/default;
        rm /etc/nginx/sites-enabled/default;
        service nginx reload
        certbot --nginx --redirect --no-eff-email --noninteractive --agree-tos -d $SERVER_HOSTNAME
        # TODO setup phpmyadmin settings

        sed -i -e "s/keyfile=.*/keyfile=\/etc\/letsencrypt\/live\/$SERVER_HOSTNAME\/privkey.pem/g" /etc/webmin/miniserv.conf
        sed -i -e "s/certfile=.*/certfile=\/etc\/letsencrypt\/live\/$SERVER_HOSTNAME\/cert.pem/g" /etc/webmin/miniserv.conf
        sed -i -e "s/extracas=.*/extracas=\/etc\/letsencrypt\/live\/$SERVER_HOSTNAME\/chain.pem/g" /etc/webmin/miniserv.conf
        grep -q -F 'certfile=' /etc/webmin/miniserv.conf
        if [ $? -ne 0 ]; then
          echo "certfile=/etc/letsencrypt/live/$SERVER_HOSTNAME/cert.pem" >> /etc/webmin/miniserv.conf
        fi
        grep -q -F 'extracas=' /etc/webmin/miniserv.conf
        if [ $? -ne 0 ]; then
          echo "extracas=/etc/letsencrypt/live/$SERVER_HOSTNAME/chain.pem" >> /etc/webmin/miniserv.conf
        fi
        service webmin restart
    fi
    echo ""
}

install-webmin() {
    packageinstalled=$(dpkg-query -W -f='${Status}' webmin 2> /dev/null)
    if [[ $packageinstalled != "install ok installed" ]] ; then
        if [[ $interactive == $YES ]]; then
            printf $cl_info"Install Webmin? "$clear
            yes-no "(y/n)"
            echo "";
        fi
        if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
            echo -e $cl_info "Installing Webmin" $clear
            if [[ $simulated == 1 ]]; then
                echo -e $cl_cons"$console wget http://www.webmin.com/jcameron-key.asc &> /dev/null"
                echo -e "$console apt-key add jcameron-key.asc &> /dev/null"
                echo -e "$console cat > /etc/apt/sources.list.d/webmin.list << EOF .... EOF"
                echo -e "$console apt update &> /dev/null"
                echo -e "$console apt install webmin"
                echo -e "$console sed -i -e 's/homedir_perms=.*/homedir_perms=0750/g' /etc/webmin/useradmin/config"
                echo -e "$console chmod 711 /home" $clear
            else
                wget http://www.webmin.com/jcameron-key.asc &> /dev/null
                apt-key add jcameron-key.asc &> /dev/null

                # TODO check if file exists first.
                if ! grep -q download.webmin.com/download/repository /etc/apt/sources.list.d/webmin.list; then
                    cat > /etc/apt/sources.list.d/webmin.list << EOF
deb http://download.webmin.com/download/repository sarge contrib
deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib
EOF
                fi

                apt update &> /dev/null;
                apt install -y webmin
                echo -e $cl_info "Webmin Installed" $clear

                # Setup default home directory permissions. Must be done after webmin is installed
                sed -i -e 's/homedir_perms=.*/homedir_perms=0750/g' /etc/webmin/useradmin/config

                if [[ -f /etc/mysql/mariadb.cnf  ]]; then
                    sed -i -e 's/my_cnf=.*/my_cnf=\/etc\/mysql\/mariadb.cnf/g' /etc/webmin/mysql/config
                fi

                chmod 711 /home

                cat > /etc/webmin/custom/127001.cmd << EOF
service php7.3-fpm restart
Restart PHP-FPM
root 0 0 0 0 0 0 0 -
EOF
                echo "" > /etc/webmin/custom/127001.html

                cat > /etc/webmin/custom/127002.cmd << EOF
find /home/ \( -path "*.com" -o -path "*.ca" -o -path "*.net" \) -type d -exec du -sh '{}' \;
Home Folder Sizes
root 0 0 0 0 0 0 0 -
EOF
                echo "" > /etc/webmin/custom/127002.html
            fi
            WEBMIN_INSTALLED=$INSTALLED
        fi
    else
        WEBMIN_INSTALLED=$YES
        echo -e $cl_warn "Webmin Already Installed" $clear
    fi

    if [[ $NGINX_INSTALLED != $NO ]]; then
        if [[ $simulated == 1 ]]; then
            echo -e $cl_cons"$console wget https://www.justindhoffman.com/sites/justindhoffman.com/files/nginx-0.11.wbm_.gz"
            echo -e "$console mv nginx-0.11.wbm_ nginx-0.11.wbm"
            echo -e "$console /usr/share/webmin/install-module.pl nginx-0.11.wbm" $clear
        else
            wget https://www.justindhoffman.com/sites/justindhoffman.com/files/nginx-0.11.wbm_.gz
            mv nginx-0.11.wbm_ nginx-0.11.wbm
            /usr/share/webmin/install-module.pl nginx-0.11.wbm
        fi
    fi
}

install-database() {
    packageinstalled=$(dpkg-query -W -f='${Status}' mariadb-server 2> /dev/null)
    if [[ $packageinstalled != "install ok installed" ]] ; then
        if [[ $interactive == $YES ]]; then
            printf $cl_info"Install MariaDB? "$clear
            yes-no "(y/n)"
            echo "";
        fi
        if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
            echo -e $cl_info "Installing MariaDB" $clear
            if [[ $simulated == 1 ]]; then
                echo -e "\e[0m$console apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8\e[0m"
                echo -e "\e[0m$console cat > /etc/apt/sources.list.d/mariadb.list << EOF ... EOF\e[0m"
                echo -e "\e[0m$console apt update\e[0m"
                echo -e $cl_cons"$console apt install -y mariadb-server" $clear

            else
                apt install software-properties-common
                apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8

                if ! grep -q download.webmin.com/download/repository /etc/apt/sources.list.d/webmin.list; then
                    cat > /etc/apt/sources.list.d/mariadb.list << EOF
# MariaDB 10.4 repository list - created 2018-08-16 23:46 UTC
# http://downloads.mariadb.org/mariadb/repositories/
deb [arch=ppc64el,arm64,amd64] http://mariadb.mirror.iweb.com/repo/10.4/ubuntu bionic main
# deb-src [arch=ppc64el,arm64,amd64] http://mariadb.mirror.iweb.com/repo/10.4/ubuntu bionic main
EOF
                fi
                apt update
                apt install -y mariadb-server

            fi
            MARIADB_INSTALLED=$INSTALLED
        fi
    else
        MARIADB_INSTALLED=$YES
        echo -e $cl_warn "MariaDB Already Installed" $clear
    fi
}

install-php() {
    packageinstalled=$(dpkg-query -W -f='${Status}' php7.3 2> /dev/null)
    if [[ $packageinstalled != "install ok installed" ]] ; then
        if [[ $interactive == $YES ]]; then
            printf $cl_info"Install PHP7.3-fpm? "$clear
            yes-no "(y/n)"
            echo "";
        fi
        if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
            echo -e $cl_info "Installing PHP7.3-fpm" $clear
            if [[ $simulated == 1 ]]; then
                echo -e $cl_cons"$console add-apt-repository ppa:ondrej/php -y"
                echo -e "$console apt install php7.3 php7.3-cli php7.3-curl php7.3-fpm php7.3-gd php7.3-imap php7.3-json php7.3-mysql php7.3-sqlite3 php7.3-tidy php7.3-mbstring php7.3-dom php7.3-xml"
                echo -e "$console apt install composer -y" $clear
            else
                add-apt-repository ppa:ondrej/php -y
                apt install -y -q php7.3 php7.3-bz2 php7.3-cli php7.3-curl php7.3-fpm php7.3-gd php7.3-imap php7.3-json php7.3-mysql php7.3-sqlite3 php7.3-tidy php7.3-mbstring php7.3-xml php7.3-zip
                apt install -y -q composer
            fi
            PHP_INSTALLED=$INSTALLED
        fi
    else
        PHP_INSTALLED=$YES
        echo -e $cl_warn "PHP7.3-fpm Already Installed" $clear
    fi
}

install-nginx() {
    packageinstalled=$(dpkg-query -W -f='${Status}' nginx-extras 2> /dev/null)
    if [[ $packageinstalled != "install ok installed" ]] ; then
        if [[ $interactive == $YES ]]; then
            printf $cl_info"Install Nginx? "$clear
            yes-no "(y/n)"
            echo "";
        fi
        if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
            echo -e $cl_info "Installing Nginx" $clear
            if [[ $simulated == 1 ]]; then
                echo -e $cl_cons"$console apt install nginx-extras -y" $clear
                echo -e "$console cat > /etc/nginx/snippets/location-standard.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/location-wikimedia.conf << EOF .... EOF"

                echo -e "$console cat > /etc/nginx/snippets/autoloads.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/cache-file-descriptors.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/cross-domain-insecure.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/expires.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/extra-security.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/fastcgi-params.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/fastcgi-php.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/no-transform.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/protect-system-files.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/ssl-intermediate.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/ssl-modern.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/ssl-stapling.conf << EOF .... EOF"
                echo -e "$console cat > /etc/nginx/snippets/x-ua-compatible.conf << EOF .... EOF"
                # TODO install webmin nginx module
            else
                apt install -y -q nginx-extras

                wget -qO /etc/nginx/snippets/location-standard.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/location-standard.conf;
                wget -qO /etc/nginx/snippets/location-wikimedia.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/location-wikimedia.conf;
                wget -qO /etc/nginx/snippets/autoloads.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/autoloads.conf;
                wget -qO /etc/nginx/snippets/cache-file-descriptors.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/cache-file-descriptors.conf;
                wget -qO /etc/nginx/snippets/cross-domain-insecure.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/cross-domain-insecure.conf;
                wget -qO /etc/nginx/snippets/expires.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/expires.conf;
                wget -qO /etc/nginx/snippets/extra-security.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/extra-security.conf;
                wget -qO /etc/nginx/snippets/fastcgi-params.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/fastcgi-params.conf;
                wget -qO /etc/nginx/snippets/no-transform.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/no-transform.conf;
                wget -qO /etc/nginx/snippets/protect-system-files.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/protect-system-files.conf;
                wget -qO /etc/nginx/snippets/ssl-intermediate.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/ssl-intermediate.conf;
                wget -qO /etc/nginx/snippets/ssl-modern.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/ssl-modern.conf;
                wget -qO /etc/nginx/snippets/ssl-stapling.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/ssl-stapling.conf;
                wget -qO /etc/nginx/snippets/x-ua-compatible.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/x-ua-compatible.conf;
                wget -qO /etc/nginx/conf.d/gzip.conf https://raw.githubusercontent.com/recognizerHD/lemp-installer/$GITHUB_BRANCH/nginx-snippets/gzip.conf;

                if [[ $PAPERTRAIL_INSTALLED == $INSTALLED ]]; then
                # TODO nginx.conf needs the access_log line commented out if this goes in.
                    cat > /etc/nginx/conf.d/papertrail.conf << EOF
log_format main '[31m\$remote_addr[0m - \$remote_user [\$time_local] [35m\$status[0m [44m \$host [0m [34m"\$request"[0m \$body_bytes_sent "\$http_referer" "\$http_user_agent" "\$http_x_forwarded_for"';
access_log /var/log/nginx/access.log main;
EOF

                fi
            fi
            NGINX_INSTALLED=$INSTALLED
        fi
    else
        NGINX_INSTALLED=$YES
        echo -e $cl_warn "Nginx Already Installed" $clear
    fi
}

install-letsencrypt() {
    packageinstalled=$(dpkg-query -W -f='${Status}' certbot 2> /dev/null)
    if [[ $packageinstalled != "install ok installed" ]] ; then
        if [[ $interactive == $YES ]]; then
            printf $cl_info"Install LetsEncrypt? "$clear
            yes-no "(y/n)"
            echo "";
        fi
        if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
            echo -e $cl_info "Installing LetsEncrypt" $clear
            if [[ $simulated == 1 ]]; then
                echo -e $cl_cons"$console add-apt-repository universe -y"
                echo -e "$console add-apt-repository ppa:certbot/certbot -y"
                echo -e "$console apt install -y -q certbot python-certbot-nginx" $clear
            else
                add-apt-repository universe -y
                add-apt-repository ppa:certbot/certbot -y
                apt install -y -q certbot python-certbot-nginx
                certbot register
                # This might already be set up by default.
#                ( crontab -l 2>/dev/null; echo "00 03 * * * certbot renew" ) | crontab
            fi
            LETSENCRYPT_INSTALLED=$INSTALLED
        fi
    else
        LETSENCRYPT_INSTALLED=$YES
        echo -e $cl_warn "LetsEncrypt Already Installed" $clear
    fi
}

install-fail2ban() {
    sshd_port=22
    if [[ $interactive == $YES ]]; then
        printf $cl_info"Change SSH Port? "$clear
        yes-no "(y/n)"
        echo "";
    fi
    if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
        port_loop=true
        while [ $port_loop == true ]
        do
            read -p "Enter a new SSHD port: " sshd_port
            if [[ $sshd_port =~ ^[0-9]*[$]?$ ]]; then
                printf $cl_info"Continue with port $cl_high$sshd_port$cl_info? "$clear
                yes-no "(y/n/c)" "abort"
                echo "";
                if [[ $RETURNVAR == $YES ]]; then
                    port_loop=false
                elif [[ $RETURNVAR == $SKIP ]]; then
                    sshd_port=22
                    port_loop=false
                fi
            else
                clear-line;
                printf $cl_errr"Port "$cl_high$sshd_port$cl_errr" is not valid. Try again? "$clear
                yes-no "(y/n)"
                if [[ $RETURNVAR == $NO ]]; then
                    echo "";
                    sshd_port=22
                    port_loop=false
                fi
            fi
        done
    fi

    if [[ $simulated == 1 ]]; then
        echo -e $cl_cons"$console sed -i -e \"s/Port .*/Port $sshd_port/g\" /etc/ssh/sshd_config" $clear
    else
        grep -q ^Port /etc/ssh/sshd_config
        if [ $? -ne 0 ]; then
            echo "Port $sshd_port" >> /etc/ssh/sshd_config
        else
            sed -i -e "s/Port .*/Port $sshd_port/g" /etc/ssh/sshd_config
        fi
        service ssh restart
    fi

    if [[ $interactive == $YES ]]; then
        printf $cl_info"Setup Fail2Ban? "$clear
        yes-no "(y/n)"
        echo "";
    fi
    if [[ $interactive == $NO ]] || [[ $RETURNVAR == $YES ]]; then
        echo -e $cl_info "Installing Fail2Ban" $clear
        if [[ $simulated == 1 ]]; then
            echo -e $cl_cons"$console apt install -y fail2ban" $clear
        else
            apt install -y fail2ban
            service fail2ban start

            cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = $sshd_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
            service fail2ban restart
        fi
    fi
}

setup-cleanup() {
    apt update
    apt autoremove
}

install-backupscripts() {
    echo "Installing Backup Scripts";
    mkdir /root/bin

    # Backup /etc/letsencrypt
    sleep 1;
}


GITHUB_BRANCH=master
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

cl_warn=$yellowbold
cl_errr=$redbold
cl_info=$blue
cl_high=$cyan
cl_cons=$purple

interactive=1
returndirectory=$PWD
mkdir /tmp/mfss &> /dev/null
cd /tmp/mfss
console="simul@ted:~#"
if [[ ${1} == "live" ]]; then
    simulated=0
else
    simulated=1
fi





show-intro;
setup-vim;
setup-hostname;
setup-various;
progress-bar 10
setup-papertrail;

# after running this.
create-user;
progress-bar 20

install-letsencrypt;
progress-bar 30
install-database;
progress-bar 40
install-php;
progress-bar 50
install-nginx;
progress-bar 60
install-webmin;
progress-bar 70
if [[ $NGINX_INSTALLED == $INSTALLED ]]; then
    create-hosting-user;
fi
install-fail2ban
progress-bar 80

# Develop This
install-backupscripts;
progress-bar 90
setup-cleanup

echo -e $greenbold "Installation complete.\n" $clear
cd $returndirectory
