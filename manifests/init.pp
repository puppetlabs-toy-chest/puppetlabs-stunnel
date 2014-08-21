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
# [*tuns*]
#   A hash for tunnels, configured via hiera, example:
#    stunnel::tuns:
#           'test':
#              accept: '33066'
#              connect: '3306'
#              certificate: '/etc/stunnel/stunnel.pem'
#              private_key: '/etc/stunnel/stunnel.pem'
#              ca_file: ''
#              crl_file: ''
#              chroot: '/var/lib/stunnel4/'
#              user: 'stunnel4'
#              group: 'stunnel4'
#              pid_file: '/stunnel4.pid'
#              client: false
#  host level tunnels can also be configured in hiera and by default will be merged 
#  together with any gloals
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
  $package   = $stunnel::params::package,
  $service   = $stunnel::params::service,
  $conf_dir  = $stunnel::params::conf_dir,
  $tuns      = $stunnel::params::tuns,
  $mergetuns = $stunnel::params::mergetuns
) inherits stunnel::params {

  package { $package:
    ensure => present,
  }

  file { $conf_dir:
    ensure  => directory,
    require => Package[$package],
    purge   => true,
    recurse => true,
  }

  if $osfamily == "Debian" {
    exec { 'enable stunnel':
      command => 'sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/stunnel4',
      path    => [ '/bin', '/usr/bin' ],
      unless  => 'grep "ENABLED=1" /etc/default/stunnel4',
      require => Package[$package],
      before  => Service[$service],
    }

    # There isn't a sysvinit script installed by the "stunnel" package on
    # Red Hat systems.
    service { $service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
    }
  }

  if (($host["stunnel::tuns"]) or ($tuns)) {
    #create tunnels
    $custom_tuns = $host["stunnel::tuns"]
    $tunnels = $custom_tuns ? {
      undef => $tuns,
      default => merge($tuns, $custom_tuns),
    }
    validate_hash($tunnels)
    create_resources(stunnel::tun, $tunnels)  
  }
}
