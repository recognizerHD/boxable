#!/usr/bin/perl
# boxable-lib.pl
# Common functions for managing boxable websites for migration to other servers easily.
#

BEGIN { push(@INC, ".."); };
use WebminCore;
use File::Basename;
&init_config();

# config defaults
$config{'nginx_dir'} = $config{'nginx_dir'} || '/etc/nginx';
$config{'virt_dir'} = $config{'virt_dir'} || "$config{'nginx_dir'}/sites-available";
$config{'link_dir'} = $config{'link_dir'} || "$config{'nginx_dir'}/sites-enabled";
$config{'boxable_site_dir'} = $config{'boxable_site_dir'} || '/etc/boxable/sites';

our %nginfo = &nginx_get_info();

# nginx_find()
# Returns the path to the nginx executable
sub nginx_find
{
	return $config{'nginx_dir'}
	if (-x &translate_filename($config{'nginx_dir'}) && 
		-d &translate_filename($config{'nginx_dir'}));

	return undef;
}

# gets info from running nginx
sub nginx_get_info
{
	my $info = &backquote_command("nginx -V 2>&1");
	my @args = split(/--/,$info);
	my %vars;
	my $i = 0;
	foreach (@args) {
		if ($_ =~ /version/) {
			my @a = split(/\//,$_);
			my @ver = split(' ',@a[1]);
			$vars{'version'} = @ver[0];
		}
		elsif ($_ =~ /=/) {
			my @a = split(/=/,$_);
			$vars{@a[0]} = @a[1];
		}
		else {
			$vars{"extra_info-$i"} = $_;
			$i++;
		}
	}
	return %vars;
}

sub nginx_is_running
{
	my $pidfile = &nginx_get_pid_file();
	return &check_pid_file($pidfile);
}

sub nginx_get_pid_file
{
# what about when the pid isnt in config or nginx?
	return $config{'pid_file'} if ($config{'pid_file'});
	return $nginfo{'pid-path'} if ($nginfo{'pid-path'});
}

sub phpfpm_is_running
{
	$running = `ps aux | grep php-fpm.*master|grep -v grep`;

	if ($running) {
		return true;
	}
	else {
		return false;
	}
}
