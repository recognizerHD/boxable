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
&ui_print_header(undef, $text{'setup_title'}, undef, "setup", 0, 0);

%nginx_info = nginx::get_nginx_info();

push(@service, "MariaDB/MySQL");
push(@version, mysql::get_mysql_version());
if (foreign_installed('mysql',1) == 2) {
	push(@status, "Ready");
} elsif (foreign_installed('mysql',1) == 1) {
	push(@status, "NOT CONFIGURED");
} else {
	push(@status,"--MISSING--");
}
if (mysql::is_mysql_running()){
	push(@running, "Running");
	push(@actions," Stop ");
} else {
	push(@running, "--STOPPED--");
	push(@actions," Start ");
}

push(@service, "Nginx");
push(@version, $nginx_info{'version'});
if(foreign_installed('nginx',1)==2) {
	push(@status, "Ready");
} elsif (foreign_installed('nginx',1) == 1) {
	push(@status, "NOT CONFIGURED");
} else {
	push(@status, "--MISSING--");
}
if(nginx::is_nginx_running()){
	push(@running, "Running");
	push(@actions, "Stop / Restart / Reload");
}
else {
	push(@running, "--STOPPED--");
	push(@actions, "Start");
}

#print Dumper(%phps{'php7_2'}->{'version'});

%phps = phpfpm_is_installed();
if (%phps) {
	foreach my $key (keys %phps) {
		push(@service, "PHP-FPM");
		push(@version, %phps{$key}->{'version'});
		push(@status, "");
		if (%phps{$key}->{'running'}) {
			push(@running, "Running");
			push(@actions, "Stop / Restart / Reload");
		} else {
			push(@running, "--STOPPED--");
			push(@actions, "Start");
		}
	}
} else {
	push(@service, "PHP-FPM");
	push(@version, '');
	push(@status, "--MISSING--");
	push(@running, "--STOPPED--");
	push(@actions, "");
}

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

print "Other things to add:<br/>
<ul>
<li>Check if nginx has the necessary snippets of configs that I'll use.</li>
<li>Can I detect the config folder for php.</li>
<li>Can I detect the folders for letsencrypt.</li>
<li>Do I have access to the database.</li>
<li>Action buttons for the various servers.</li>
<li>Is cron setup for letsencrypt.</li>
<li>Is backup task set up.</li>
<li>Are the necessary components installed?</li>
</ul>";
