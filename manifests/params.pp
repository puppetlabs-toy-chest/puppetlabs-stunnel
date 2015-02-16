# == Class: stunnel::params
#
# This class sets up the default values for the OS and global options.
#
# === Variables
#
# ==== OS Variables
#
# [*package*]
#   The package name that represents the stunnel application on your
#   distribution.
#
# [*service*]
#   The service name that represents the stunnel application on your
#   distribution.
#
# [*conf_dir*]
#   The default base configuration directory for your version on stunnel.
#
# [*pid_dir*]
#   The default base pid file directory for stunnel services.
#
# [*log_dir*]
#   The default base log file directory for stunnel services.
#
# [*lock_dir*]
#   The default base lock file directory for stunnel services.
#
# ==== Global Variables
#
# [*compression*]
#   The default compression for stunnel services.
#
# [*debug_level*]
#   The default debug level for stunnel services.
#
# [*fips*]
#   The default fips flag for stunnel services.
#
# [*foreground*]
#   The default foreground flag for stunnel services.
#
# [*log*]
#   The default logging type for stunnel services.
#
# [*output*]
#   The default log file for stunnel services.
#
# [*sockets*]
#   The default socket options for stunnel services.
#
# [*syslog*]
#   The default syslog flag for stunnel services.
#
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
# Sam Kottler <shk@linux.com>
# Josh Preston
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
class stunnel::params {

  case $::osfamily {

    AIX: {
      $conf_dir = '/etc/stunnel'
      $pid_dir  = '/var/run'
      $log_dir  = '/var/log/stunnel'
    }

    Debian: {
      $conf_dir = '/etc/stunnel'
      $log_dir  = '/var/log/stunnel'
      $package  = 'stunnel4'
      $pid_file = '/var/run/stunnel.pid'
      $service  = 'stunnel4'
    }

    RedHat: {
      $conf_dir = '/etc/stunnel'
      $lock_dir = '/var/lock/subsys'
      $log_dir  = '/var/log/stunnel'
      $package  = 'stunnel'
      $pid_dir  = '/var/run'
    }

    default: {
      notify { "${::osfamily} is not supported.": }
    }

  }

  $compression = 'zlib'
  $debug_level = '4'
  $fips        = 'no'
  $foreground  = 'no'
  $service     = 'stunnel'
  $log         = 'append'
  $output      = '/var/log/stunnel.log'
  $sockets     = [
                  'l:TCP_NODELAY=1',
                  'r:TCP_NODELAY=1',
                ]
  $syslog      = 'yes'
}
