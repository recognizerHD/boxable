#!/usr/bin/perl
# boxable-lib.pl
# Common functions for managing boxable websites for migration to other servers easily.
#

use WebminCore;
use File::Basename;

# config defaults
$config{'phpfpm_dir'} = $config{'phpfpm_dir'} || '/etc/php';

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
