# == Class: stunnel::params
#
# This module sets up SSL encrypted and authenticated tunnels using the
# common application stunnel.
#
# === Variables
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
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
# Sam Kottler <shk@linux.com>
# Josh Preston <joshua@prestoncentral.com>
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

  $compression = 'deflate'
  $debug_level = '4'
  $fips        = 'no'
  $foreground  = 'no'
  $log         = 'append'
  $output      = '/var/log/stunnel.log'
  $sockets     = [
                  'l:TCP_NODELAY=1',
                  'r:TCP_NODELAY=1',
                ]
  $syslog      = 'yes'
}
