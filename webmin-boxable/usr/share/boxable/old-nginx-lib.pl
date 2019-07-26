#!/usr/bin/perl
# boxable-lib.pl
# Common functions for managing boxable websites for migration to other servers easily.
#

use WebminCore;
use File::Basename;

# config defaults
#my %nginx_config = foreign_config('nginx');
#print Dumper(%nginx_config{'virt_dir'});
#print Dumper(%nginx_config{'link_dir'});
#%nginx_config{'nginx_dir'} = "".%nginx_config{'nginx_dir'} || '/etc/nginx';
#%nginx_config{'virt_dir'} = "".%nginx_config{'virt_dir'} || "".%nginx_config{'nginx_dir'}."/sites-available";
#%nginx_config{'link_dir'} = "".%nginx_config{'link_dir'} || "".%nginx_config{'nginx_dir'}."/sites-enabled";



#our %nginfo = &nginx_get_info();

# nginx_find()
# Returns the path to the nginx executable
sub anginx_find
{
	return $config{'nginx_dir'}
	if (-x &translate_filename($config{'nginx_dir'}) && 
		-d &translate_filename($config{'nginx_dir'}));

	return undef;
}

# gets info from running nginx
sub anginx_get_info
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

sub anginx_is_running
{
	my $pidfile = &nginx_get_pid_file();
	return &check_pid_file($pidfile);
}

sub anginx_get_pid_file
{
# what about when the pid isnt in config or nginx?
	return $config{'pid_file'} if ($config{'pid_file'});
	return $nginfo{'pid-path'} if ($nginfo{'pid-path'});
}
