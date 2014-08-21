# == Class: stunnel::data
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
# [*tuns*]
#   A hash of tunnels to be created
#
# [*mergetuns*]
#  Flag to determine if global and host level tunnels should be merged
#
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
# Sam Kottler <shk@linux.com>
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
class stunnel::params {
  case $osfamily {
    Debian: {
      $conf_dir = '/etc/stunnel'
      $package  = 'stunnel4'
      $service  = 'stunnel4'
    }
    RedHat: {
      $conf_dir = '/etc/stunnel'
      $package = 'stunnel'
      $service = 'stunnel'
    }
  }
  $tuns      = {}
  $mergetuns = false
}
