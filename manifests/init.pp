# == Class: stunnel
#
# This module sets up SSL encrypted and authenticated tunnels using the
# common application stunnel.
#
# === Parameters
#
# [*package*]
#   The package name that represents the stunnel application on your
#   distribution.  By default we look this value up in a stunnel::data class,
#   which has a list of common answers.
#
# [*service*]
#   The service name that represents the stunnel application on your
#   distribution.  By default we look this value up in a stunnel::data class,
#   which has a list of common answers.
#
# [*conf_dir*]
#   The default base configuration directory for your version on stunnel.
#   By default we look this value up in a stunnel::data class, which has a
#   list of common answers.
#
# === Examples
#
# include stunnel
#
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
# Josh Preston <joshua@prestoncentral.com>
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
class stunnel(
  # These are OS dependent...
  $package      = $stunnel::params::package,
  $service      = $stunnel::params::service,
  $conf_dir     = $stunnel::params::conf_dir,
  $log_dir      = $stunnel::params::log_dir,
  $pid_dir      = $stunnel::params::pid_dir,
  $chroot_dir   = $stunnel::params::chroot_dir,

  # These are stunnel global options
  $chroot       = $stunnel::params::chroot,
  $compression  = $stunnel::params::compression,
  $debug_level  = $stunnel::params::debug_level,
  $fips         = $stunnel::params::fips,
  $foreground   = $stunnel::params::foreground,
  $group        = $stunnel::params::group,
  $output       = $stunnel::params::output,
  $pid_file     = $stunnel::params::pid_file,
  $sockets      = $stunnel::params::sockets,
  $syslog       = $stunnel::params::syslog,
  $user         = $stunnel::params::user,
) inherits stunnel::params {

  if $package {
    # Make sure the package is installed
    package { $package:
      ensure => present,
      before => File[$conf_dir],
    }
  }

  # Make sure our config directory exists
  file { $conf_dir:
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

  # Make sure the pid directory exists if needed
  if ($pid_dir and !$chroot and !$chroot_dir) {
    file { $pid_dir:
      ensure  => directory,
    }
  } else {
    notify { 'Specifying chroot and pid_dir is not recommended': }
  }

  # Make sure the log directory exists if needed
  if $log_dir {
    file { $log_dir:
      ensure  => directory,
    }
  }

  # Make sure the chroot directory exists if needed
  if $chroot_dir {
    file { $chroot_dir:
      ensure  => directory,
    }
  }

  # Debian must handle stunnel differently and AIX needs telinit -q
  case $::osfamily {

    'AIX': {
      exec { 'telinit -q':
        command     => 'telinit -q',
        path        => '/usr/bin:/usr/sbin:/bin:/sbin',
        refreshonly => true,
      }
    }

    'Debian': {
      exec { 'enable stunnel':
        command => 'sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4',
        path    => [ '/bin', '/usr/bin' ],
        unless  => 'grep "ENABLED=1" /etc/default/stunnel4',
        require => Package[$package],
      } ->
      service { $service:
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => false,
      }
    }

    default: { }
  }

}
