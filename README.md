# LEMP Installer
A LEMP installer that also sets up a number of other packages that I often use.

## Disclaimer
Use at your own risk. I made this for myself but is available for anyone else to use/modify/etc.

## Getting Started

These instructions will get you running a LEMP server by the time it's finished. 

First, some small packages needed for the installation and other tasks will be installed.
You will be prompted to create a user and be set up to log in with that account instead of root.
Next, various small packages used for backups and other background processes will be installed.
Then you will be asked to install the following packages:

| Package              | Version       |
| -------------------- | ------------- |
| nginx-extras         | Latest        |
| MariaDB              | 10.1 (Latest) |
| PHP-FPM              | 7.3           |
| Webmin               | Latest        |
| Letsencrypt/Certbot  | Latest        |

### Prerequisites:
This is intended to run on a clean install of a VPS running Ubuntu 18.

**Hostname** - a fully qualified domain name. Used for the default site with nginx.\
**Papertrail hostname and port** *(optional)* - Used for logging.\
**Username for default server** - this is where phpMyAdmin will sit.\
**Username** - for your future login. You'll also supply a password when prompted.

### Installing

Run the following lines one by one. You can inspect the file to ensure you think it's safe. I make no guarantees.
```
wget -qO lempi.sh https://raw.githubusercontent.com/recognizerHD/lemp-installer/master/lempi.sh; 
chmod +x lempi.sh; 
./lempi.sh live
```
or as one line. I haven't tested the second one.
```
wget -qO lempi.sh https://raw.githubusercontent.com/recognizerHD/lemp-installer/master/lempi.sh; chmod +x lempi.sh; ./lempi.sh live

# or

sudo su -c "bash <(wget -qO- https://raw.githubusercontent.com/recognizerHD/lemp-installer/master/lempi.sh live)" root
```

The script will run and install everything else needed and offer you prompts. You can also run it without the word live like:
```
./lempi.sh 
``` 
This will run the installation script in simulation mode and show you (mostly) what it does with the prompts still.

### What it does

1. You'll be prompted to change the hostname.
2. Various packages will be installed like putty tools, rsyslog, curl, etc.
3. Papertrail is then set up for logging purposes.
4. A user is then created for you so you can use this instead of root for all future connections. It will also disable root login via password.
5. Letsencrypt/Certbot will be installed. 
6. MariaDB is then installed. As of this script, 10.1 is installed and login via root is done with sockets instead of password. No root password is necessary at this point.
7. PHP-FPM 7.3 is installed with a number of the packages that I typically install. These include:
   * bz2 cli curl fpm gd imap json mysql sqlite3 tidy mbstring xml zip
   * composer is also installed
8. Nginx is then installed and many snippets are set up for possible future use. If papertrail was set up, it also adds a custom logging format to show differently in papertrail.
9. Webmin is then installed. The mysql config file is updated to point to MariaDB and a two custom commands are added that I use. The nginx module for webmin is also installed.
10. The hosting user is then created.
   * This user is not intended to be used for managing the server. It is intended to be the default website user. phpMyAdmin is set up under this user.
   * Letsencrypt is then run to get a certificate for this default site so it is now running under SSL.
   * The webmin install is then updated to use the same certificate. 
11. Fail2Ban is installed and asks if you want to change the SSHD port.

### Future plans

I plan to also include a backup process, but I need to rewrite that anyway.


## Contributing

Please read [CONTRIBUTING.md](https://github.com/recognizerHD/model-mapper/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Paul Warren** - *Initial work* - [recognizerHD](https://github.com/recognizerHD)

See also the list of [contributors](https://github.com/recognizerHD/lemp-installer/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* 90% of this was written from examples I found on stackoverflow. I wish I could attribute everything but this code was written long before I even thought of doing that. Sorry :|
