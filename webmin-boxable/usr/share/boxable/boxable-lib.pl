#!/usr/bin/perl
# boxable-lib.pl
# Common functions for managing boxable websites for migration to other servers easily.
#

BEGIN { push(@INC, ".."); };
use WebminCore;
use Data::Dumper;
use File::Basename;
&init_config();

#require './phpfpm-lib.pl';
#require './phpfpm-lib.pl';

# config defaults
%nginx_config = foreign_config('nginx');
$nginx_config{'nginx_dir'} = "".$nginx_config{'nginx_dir'} || '/etc/nginx';
$nginx_config{'virt_dir'} = "".$nginx_config{'virt_dir'} || "".$nginx_config{'nginx_dir'}."/sites-available";
$nginx_config{'link_dir'} = "".$nginx_config{'link_dir'} || "".$nginx_config{'nginx_dir'}."/sites-enabled";

$config{'boxable_site_dir'} = $config{'boxable_site_dir'} || '/etc/boxable/sites';
$config{'boxable_nginx_default_dir'} = $config{'boxable_nginx_default_dir'} || '/etc/boxable/setup/nginx-site.conf';

foreign_require('nginx','nginx-lib.pl');
foreign_require('mysql','mysql-lib.pl');
#foreign_require('mysql','install_check.pl');

sub phpfpm_is_installed
{
    my %php;
    if (`php-fpm7.2 -version`) {
        #$php{'php7_2'}{'installed'} = true;
        if (`ps x | grep "[f]pm".*master.*/7.2/`) {
            $running = true;
        } else {
            $running = false;
        }

        $php{'php-fpm7.2'} = {
            'version' => '7.2',
            'running' => $running,
            'installed' => true
        };
    }
    if (`php-fpm7.3 -version`) {
        if (`ps x | grep "[f]pm".*master.*/7.3/`) {
            $running = true;
        } else {
            $running = false;
        }

        $php{'php-fpm7.3'} = {
            'version' => '7.3',
            'running' => $running,
            'installed' => true
        };
    }
    return %php;
    # $running7_2 = `php-fpm7.2 -version`;
    # $running7_3 = `php-fpm7.3 -version`;
    # $running7_4 = `php-fpm7.4 -version`;
    # $running8_0 = `php-fpm8.0 -version`;
}

sub nginx_find
{
    return "".$nginx_config{'nginx_dir'}
    if (-x &translate_filename("".$nginx_config{'nginx_dir'}) &&
        -d &translate_filename("".$nginx_config{'nginx_dir'}));

    return undef;
}


# turns list of icons into link,text,icon table
sub config_icons
{
    local (@titles, @links, @icons);
    for($i=0; $i<@_; $i++) {
        push(@links, $_[$i]->{'link'});
        push(@titles, $_[$i]->{'name'});
        push(@icons, $_[$i]->{'icon'});
    }
    &icons_table(\@links, \@titles, \@icons, 3);
    print "<p>\n";
}

sub get_boxable_sites
{
    my $dir = "$config{'boxable_site_dir'}";
    my @files = grep{-d $_}glob("$dir/*");
    return @files;
}


# find_directive(file, name)
# Returns the values of directives matching some name
sub find_directives
{
  local ($file, $name) = @_;
  local %config;
  local $skip = 1;
  &open_readfile(CONF, $file);
  while ($line = <CONF>) {
    $line =~ s/^\s*#.*$//g;
    if ($line =~ /server \{$/) {
      $skip = 0;
    }
    if ($line =~ /}$/) {
      $skip = 1;
    }
    next if $skip;
    if ($line =~ /^\s*(\w+)\s*(\S+).*;$/) {
      if (!$config{$1}) {
        $config{$1} = $2;
      }
    }
  }
  close(CONF);

  return $config{$name};
}
