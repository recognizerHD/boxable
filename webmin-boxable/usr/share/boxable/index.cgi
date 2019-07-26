#!/usr/bin/perl
# index.cgi
# Display a list of all boxable sites
# Read: https://doxfer.webmin.com/Webmin/Module_Development
# AND: https://doxfer.webmin.com/Webmin/API_Webmin-Core#ui_columns_row.28.26columns.2C_.26tdtags.29

use HTML::Entities;
use Data::Dumper;
require './boxable-lib.pl';
&ReadParse();

# Page header

#
&ui_print_header(undef, $text{'index_title'}, undef, "intro", 1, 1);

$old_index = {
	"name" => "Old Index",
	"link" => "oldindex.cgi" };

$new_site = {
	'icon' => 'images/blocks.gif',
	"name" => "New Site",
	"link" => "new_site.cgi" };

$import_site = {
	'icon' => 'images/folder_open.gif',
	'name' => "Import Site",
	'link' => 'import_site.cgi' };

$list_sites = {
	"icon" => "images/sites.gif",
	"name" => "Existing Sites",
	"link" => "list_sites.cgi" };

$setup = {
	"icon" => "images/cog.gif",
	"name" => "Setup Info",
	"link" => "setup.cgi",
	};

$todo = {
	"name" => "Todo List",
	"link" => "todo.cgi",
	};


&config_icons( $old_index, $list_sites, $new_site, $import_site, $setup, $todo );

	$running = `php-fpm7.3 -version`;
	print Dumper("".$running);
#$zone = &running_in_zone() || &running_in_vserver();
#foreach $i ('ifcs', 'routes', 'dns', 'hosts',
#	    ($config{'ipnodes_file'} ? ('ipnodes') : ( ))) {
#	next if (!$access{$i});
#	next if ($i eq "ifcs" && $zone);
#
#	if ($i eq "ifcs") {
#		push(@links, "list_${i}.cgi");
#		}
#	else {
#		push(@links, "list_${i}.cgi");
#		}
#	push(@titles, $text{"${i}_title"});
#	push(@icons, "images/${i}.gif");
#	}
#  &icons_table(\@links, \@titles, \@icons, @icons > 4 ? scalar(@icons) : 4);
#
#if (defined(&apply_network) && $access{'apply'} && !$zone) {
#	# Allow the user to apply the network config
#	print &ui_hr();
#	print &ui_buttons_start();
#	print &ui_buttons_row("apply.cgi", $text{'index_apply'},
#			      $text{'index_applydesc'});
#	print &ui_buttons_end();
#	}
#&ui_print_footer("/", $text{'index'});



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
