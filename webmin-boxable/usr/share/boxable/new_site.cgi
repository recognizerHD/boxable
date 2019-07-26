#!/usr/bin/perl
# new_site.cgi
# Read: https://doxfer.webmin.com/Webmin/Module_Development
# AND: https://doxfer.webmin.com/Webmin/API_Webmin-Core#ui_columns_row.28.26columns.2C_.26tdtags.29

use HTML::Entities;
use Data::Dumper;
require './boxable-lib.pl';
&ReadParse();
init_config();

# Page header
&ui_print_header(undef, $text{'new_site_title'}, undef, "newsite", 0, 0);

my $file = "".$config{'boxable_nginx_default'};
if (!-e $file){
	$file = "setup/nginx-site.conf";
}

print &ui_form_start("create_boxable.cgi","form-data");
	print &ui_hidden_table_start("Create Site", undef, 2, "basic", 1);
		print &ui_table_row("User", &ui_user_textbox("user",""));
		print &ui_table_row("Site Name", &ui_textbox("sitename", undef, 40, undef, undef, 'placeholder="Site Name"'));
		print &ui_table_row("Server Name", &ui_textbox("servername", undef, 60));
		print &ui_table_row("Restore / Initial Files (optional)", &ui_upload("file_upload",60));
	print &ui_hidden_table_end();
	print &ui_hidden_table_start("Advanced Settings", undef, 2, "advanced", 0);
	#		print &ui_table_row("New | Existing User radio, with text option", );
	#	print &ui_table_row("Listen IPv4", &ui_opt_textbox("listen_ip4", undef, 30, "[::]:80"));
		print &ui_table_row("Subfolder Document Root", &ui_textbox("subfolder_root", undef, 40));
		print &ui_table_row("Database Password (optional)",	&ui_textbox("database_password", undef, 40));
	print &ui_hidden_table_end();
	print &ui_hidden_table_start("Nginx Configuration Template", undef, 2, "nginx", 1);
		$lref = &read_file_lines($file,1);
		if (!defined($start)) {
			$start = 0;
			$end = @$lref - 1;
		}
		$buffer = "";
		for($i=$start; $i<=$end; $i++) {
			$buffer .= $lref->[$i]."\n";
		}
		print &ui_table_row("Nginx Config", &ui_textarea("webserver_config", $buffer, 25,80, undef, undef, "style='width:100%'"));

		print &ui_table_row("",
			&ui_submit($text{'save'}));

	print &ui_hidden_table_end();
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
