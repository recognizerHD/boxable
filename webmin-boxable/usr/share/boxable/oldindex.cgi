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
&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);

@tabs = (['setup', $text{'tab_setup'}], ['existing', $text{'tab_existing'}], ['create',$text{'tab_create'}], ['todo',$text{'tab_todo'}] );

print ui_tabs_start(\@tabs, 'mode', 'existing' );

@sites = nginx::get_servers();
print Dumper(@sites);


#foreign_require("servers", "servers-lib.pl");
#my $nginx_config = &foreign_config('nginx',0);
#print Dumper($nginx_config);


print ui_tabs_start_tab('mode', 'setup');
	push(@service, "Nginx");
	push(@version, $nginfo{'version'});
    if(&nginx_find()){
		push(@status, "Installed");
    }
    else {
		push(@status, "--MISSING--");
    }
    if(&nginx_is_running()){
        push(@running, "Running");
	    push(@actions, "Stop / Restart / Reload");
    }
    else {
	    push(@running, "--STOPPED--");
        push(@actions, "Start");
    }

	push(@service, "PHP-FPM");
	push(@version, 'N/A');
	push(@status, "N/A");
	if (&phpfpm_is_running()){
		push(@running, "Running");
	    push(@actions, "Stop / Restart / Reload");
	} else {
  	    push(@running, "--STOPPED--");
        push(@actions, "Start");
	}

    push(@service, "MariaDB/MySQL");
    push(@version, 'N/A');
    push(@status, "N/A");
    push(@running, "N/A");

    push(@service, "LetsEncrypt");
    push(@version, 'N/A');
    push(@status, "N/A");
    push(@running, "N/A");

    print &ui_columns_start([
			$text{'index_setup_name'},
			$text{'index_setup_status'},
			$text{'index_setup_version'},
			$text{'index_setup_running'}], 100);
	
  	for($i=0; $i<@service; $i++) {
  		my @cols;
  		push(@cols, "$service[$i]");
  		push(@cols, "$status[$i]");
  		push(@cols, "$version[$i]");
  		push(@cols, "$running[$i]");
  		print &ui_columns_row(\@cols, undef);
  	}
  	print &ui_columns_end();


	
print ui_tabs_end_tab('mode', 'setup');

print ui_tabs_start_tab('mode', 'existing');
	my @sites = &get_boxable_sites();
	foreach $site (@sites) {
		$sn = basename($site);
	#	$status = '<span style="color:darkgreen">' . $text{'status_enabled'} . '</span>';
	#	push(@servername, $sn)
	#	push(@enabled,"?");
	#	push(@docroot,"/home/user/domain.com/public");
	#	push(@letsencrypt, "$status");
	#	push(@vlink, "edit_boxable.cgi?editfile=$sn");
	}

	# table list of items 
	# # disable site ? 
	# # sortable
	print &ui_columns_start([
			'domain',
			'enabled?',
			'document_root',
			'letsencrypt',
			'user:group',
			'php: dynamic/#/#',
			'mysqluser:database',
		],100);


	print &ui_columns_end();

	#print Dumper(%module_info);

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
print ui_tabs_end_tab('mode','existing');

print ui_tabs_start_tab('mode', 'create');
	print &ui_form_start("create_boxable.cgi","form-data");
		print &ui_table_start("Create", undef, 2);
		
			print &ui_table_row("New User | Existing Users ... Radio, with text option");

			print &ui_table_row("Server Name", 
				&ui_textbox("servername", undef, 40));

			print &ui_table_row("Restore / Initial Files (optional)");

			print &ui_table_row("Subfolder Root (optional)",
				&ui_textbox("subfolder_root", undef, 40));

			print &ui_table_row("Database Password (optional)",
				&ui_textbox("database_password", undef, 40));

			print &ui_table_row("<hr>","<hr>");
			print &ui_table_row("Webserver Config",
				&ui_textarea("webserver_config", undef, 25,80, undef, undef, "style='width:100%'"));

			print &ui_table_row("",
				&ui_submit($text{'save'}));

		print &ui_table_end();
	print &ui_form_end();

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
print ui_tabs_end_tab('mode','create');

print ui_tabs_start_tab('mode','todo');

print ui_tabs_end_tab('mode','todo');
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
