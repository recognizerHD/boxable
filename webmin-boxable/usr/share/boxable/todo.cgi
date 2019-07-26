#!/usr/bin/perl
# index.cgi
# Display a list of all boxable sites
# Read: https://doxfer.webmin.com/Webmin/Module_Development
# AND: https://doxfer.webmin.com/Webmin/API_Webmin-Core#ui_columns_row.28.26columns.2C_.26tdtags.29

use HTML::Entities;
require './boxable-lib.pl';
&ReadParse();

# Page header

#
&ui_print_header(undef, $text{'todo_title'}, "");

print "
<h4>Create site form.</h4><br/>
1. Read from customized nginx template. Put the value into the textarea. <br/>
2. If the customized nginx template is not there, read from the default one. The that comes with the boxable module.<br/>
3. Clicking save will create a new user. Check to see if the user exists, handle errors etc.<br/>
4. Dropdown option to select existing user. with Text field to create a new one.<br/> (Required)
5. Textbox to define the domain the work on. (Required) This is the default server_name if (servername is not defined), and the file name. and the folder name too.<br/>
6. ServerName alternative. Allow for a pure text, regex. This is optional. If empty, server_name is defined by the option above.<br/>
7. Doc_root. (optional) If defined, this is what the root is. Useful for laravel.<br/>
8. File Upload - If defined, uploads files. If files already exist in target folder, abort.<br/>

X. Do all the checks before actually starting to make changes.

";


	# letsencrypt
	# Do the handshake to set up the site.
	# After success, update the config to include the two ssl specific config snippets
	#
	#
	# on manual backup
	# backup the database for that user
	# create the SQL script to recreate the user & permissions (database password needed)
	# copy the nginx customizations to a file
	# copy the php-fpm info
	# copy anything else that is required to set up a site.
	# zip it all up and download to the user.
	#
	# Options to allow for extra files to be included?
	# Options to include extra databases.
	#
	# Automated backups will sync to the google drive. Each site will have it's own backup file.
	#print ui_tabs_end_tab('mode','existing');


	# Radio, with text option
	# New user | Existing Users
	#				List All users with home directories
	# 
	# Text field
	# Domain to operate under
	#
	# File Uploader (optional)
	# Can be restore file, or intial files to put in folder. All files will go into a folder under /home/{user}/{domain}
	#
	# Text field (optional)
	# folder to setup for making the initial nginx file public. If a value exists, it will create if necessary. useful for laravel which has a subfolder of 'public'
	#
	# Radio, Database Password (optional)
	# If supplied, will create a user with the password supplied.
	#
	# --- on process:
	# check if user option is valid
	# check if domain has already been used
	# check if file is zipped or gzipped.
	# 
	# if all is good,
	# create user/group if user is new
	# create php-fpm with socket info
	# restart php-fpm
	#
	# Unzip files into temp folder and inspect.	# 
	# =====
	# If no files or files were not a restore:
	#
	# create folder /home/{user}/{domain}/{optional}
	# unzips files into /home/{user}/{domain}
	# chown everything
	# 
	# create nginx config site (using non-ssl version)
	# create link to make site enabled
	# reload nginx
	# ## IF fails, remove config file and show error.
	#
	# create database 
	# create database user & set password
	# grant permission to database to user
	#
	# =====
	# If files were a restore: (requires a boxable.info file in the root of the zip)
	#
	# run script to restore database. overwrite if necessary
	# run script to copy files to domain folder. overwrite
	# chown everything
	# copy php-fpm config
	# restart php-fpm
	# copy nginx config
	# copy letsencrypt cert and key and config (if exists)
	# reload nginx
	#

	
	
	
	# Properly detect if installed, running, the version ,etc.
# Show action buttons like restart / stop / startp etc
# Check the setup for the backup method, i.e. dropbox or google drive.
# Setup phpmyadmin
#
# List the sites that are currently set up.
# provide edit options ? 
# Other actions include: delete and leave, delete and purge, edit, backup, restore, setup lets encrypt
#
# Create form:
# new user / existing user
# domain.com
# zip of files to install initially
#
