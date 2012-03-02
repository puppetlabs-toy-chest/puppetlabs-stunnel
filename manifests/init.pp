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
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
class stunnel(
  $package  = $stunnel::data::package,
  $service  = $stunnel::data::service,
  $conf_dir = $stunnel::data::conf_dir
) inherits stunnel::data {

  package { $package:
    ensure => present,
  }

  file { $conf_dir:
    ensure  => directory,
    require => Package[$package],
    purge   => true,
    recurse => true,
  }

  exec { 'enable stunnel':
    command => 'sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4',
    path    => [ '/bin', '/usr/bin' ],
    unless  => 'grep "ENABLED=1" /etc/default/stunnel4',
    require => Package[$package],
    before  => Service[$service],
  }

  service { $service:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
  }
}
