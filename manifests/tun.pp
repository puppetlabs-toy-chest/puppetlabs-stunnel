# == Define: stunnel::tun
#
# Creates a tunnel config to be started by the stunnel application on startup.
#
# === Parameters
#
# [*namevar*]
#   The namevar in this type is the title you give it when you define a resource
#   instance.  It is used for a handful of purposes; defining the name of the
#   config file and the tunnel section in the config, as well as things like
#   the PID file.
#
# [*certificate*]
#   Signed SSL certificate to be used during authentication and encryption.
#   This module is meant to work in conjuction with an already established
#   Puppet infrastructure so we are defaulting to the default location of the
#   agent certificate on Puppet Enterprise.
#
# [*private_key*]
#   In order to encrypt and decrypt things there needs to be a private_key
#   someplace among the system.  Just like certificate we use data from Puppet
#   Enterprise.
#
# [*ca_file*]
#   The CA to use to validate client certificates.  We default to that
#   distributed by Puppet Enterprise.
#
# [*crl_file*]
#   Currently OCSP is not supported in this module so in order to know if a
#   certificate has not been revoked, you will need to load a revocation list.
#   We default to the one distributed by Puppet Enterprise.
#
# [*ssl_version*]
#   Which SSL version you plan to enforce for this tunnel.  The preferred and
#   default is TLSv1.
#
# [*chroot*]
#   To protect your host the stunnel application runs inside a chrooted
#   environment.  You must devine the location of the processes' root
#   directory.
#
# [*user*]
#   The stunnel application is capable of running each defined tunnel as a
#   different user.
#
# [*group*]
#   The stunnel application is capable of running each defined tunnel as a
#   different group.
#
# [*pid_file*]
#   Where the process ID of the running tunnel is saved.  This values needs to
#   be relative to your chroot directory.
#
# [*debug_level*]
#   The debug leve of your defined tunnels that is sent to the log.
#
# [*log_dest*]
#   The file that log messages are delivered to.
#
# [*client*]
#   If we running our tunnel in client mode.  There is a difference in stunnel
#   between initiating connections or listening for them.
#
# [*accept*]
#   For which host and on which port to accept connection from.
#
# [*connect*]
#  What port or host and port to connect to.
#
# [*conf_dir*]
#   The default base configuration directory for your version on stunnel.
#   By default we look this value up in a stunnel::data class, which has a
#   list of common answers.
#
# === Examples
#
#   stunnel::tun { 'rsyncd':
#     certificate => "/etc/puppet/ssl/certs/${::clientcert}.pem",
#     private_key => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
#     ca_file     => '/etc/puppet/ssl/certs/ca.pem',
#     crl_file    => '/etc/puppet/ssl/crl.pem',
#     chroot      => '/var/lib/stunnel4/rsyncd',
#     user        => 'pe-puppet',
#     group       => 'pe-puppet',
#     client      => false,
#     accept      => '1873',
#     connect     => '873',
#   }
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
define stunnel::tun (
  # These are OS dependent...
  $package      = $::stunnel::package,
  $service      = $::stunnel::service,
  $conf_dir     = $::stunnel::conf_dir,
  $log_dir      = $::stunnel::log_dir,
  $pid_dir      = $::stunnel::pid_dir,
  $chroot_dir   = $::stunnel::chroot_dir,
  # These are stunnel global options - use global first
  $chroot       = $::stunnel::chroot,
  $compression  = $::stunnel::compression,
  $debug_level  = $::stunnel::debug_level,
  $fips         = $::stunnel::fips,
  $foreground   = $::stunnel::foreground,
  $group        = $::stunnel::group,
  $log_dir      = $::stunnel::log_dir,
  $output       = $::stunnel::output,
  $pid_file     = $::stunnel::pid_file,
  $sockets      = $::stunnel::sockets,
  $syslog       = $::stunnel::syslog,
  $user         = $::stunnel::user,
  # These are service options
  $debug_level  = 4,
  $ssl_version  = 'TLSv1',
  $verify       = 2,
  $accept,
  $ca_dir,
  $ca_file,
  $certificate,
  $ciphers,
  $client,
  $connect,
  $crl_dir,
  $crl_file,
  $log_dest,
  $options,
  $private_key,
) {

  $ssl_version_real = $ssl_version ? {
    'tlsv1' => 'TLSv1',
    'sslv2' => 'SSLv2',
    'sslv3' => 'SSLv3',
    default => $ssl_version,
  }
  validate_re($ssl_version_real, '^SSLv2$|^SSLv3$|^TLSv1$', 'The option ssl_version must have a value that is either SSLv2, SSLv3, of TLSv1. The default and prefered option is TLSv1. SSLv2 should be avoided.')

  # Configure the client
  $client_on = $client ? {
    true    => 'yes',
    false   => 'no',
    default => $client,
  }
  validate_re($client_on, '^yes$|^no$', 'The client option must be true/false or yes/no.')

  # Configure fips
  $fips_on = $fips ? {
    true    => 'yes',
    false   => 'no',
    default => $fips,
  }
  validate_re($fips_on, '^yes$|^no$', 'The fips option must be true/false or yes/no.')

  # Configure fips
  $foreground_on = $foreground ? {
    true    => 'yes',
    false   => 'no',
    default => $foreground,
  }
  validate_re($foreground_on, '^yes$|^no$', 'The foreground option must be true/false or yes/no.')

  # Configure syslog
  $syslog_on = $syslog ? {
    true    => 'yes',
    false   => 'no',
    default => $syslog,
  }
  validate_re($syslog_on, '^yes$|^no$', 'The syslog option must be true/false or yes/no.')

  # Set our accept server and port correctly
  if $accept {
    $accept_array  = split($accept, ':')
    $accept_server = $accept_array[0]
    $accept_port   = $accept_array[1]
  } else {
    fail('No accept server:port specified!')
  }

  # Set our connect server and port correctly
  if $connect {
    $connect_array  = split($connect, ':')
    $connect_server = $connect_array[0]
    $connect_port   = $connect_array[1]
  } else {
    fail('No connect server:port specified!')
  }

  # Make sure our service line exists
  file_line { "service ${name}-tun":
    path  => '/etc/services',
    line  => "${name}-tun        ${accept_port}/tcp",
    match => "^${name}-tun",
  }

  # Create our configuration
  file { "${conf_dir}/${name}.conf":
    ensure  => file,
    content => template("${module_name}/stunnel.conf.erb"),
    mode    => '0644',
    owner   => '0',
    group   => '0',
    require => File[$conf_dir],
  }

  # If we need a chroot directory
  if $chroot_dir {
    $chroot_real = "${chroot_dir}/${name}"
  } elsif $chroot {
    $chroot_real = $chroot
  }
  if $chroot_real {
    file { $chroot_real:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0600',
    }
  }

  # If we need a log directory
  if $log_dir {
    $output_real = "${log_dir}/${name}.log"
  } elsif $log_dest {
    $output_real = $log_dest
  } elsif $output {
    $output_real = $output
  }

  case $::osfamily {

    'RedHat': {
      file { "/etc/init.d/${service}-${name}":
        ensure  => file,
        owner   => 0,
        group   => 0,
        mode    => '0755',
        content => template("${module_name}/init.d/stunnel.erb"),
        require => Package[$package],
        before  => Service["${service}-${name}"],
      } ~>
      service { "${service}-${name}":
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => File_line["service ${name}-tun"],
      }
    }

    'AIX': {
      file_line { "inittab stunnel_${name}":
        path    => '/etc/inittab',
        line    => "stunnel_${name}:2345:once:/opt/freeware/bin/stunnel ${conf_dir}/${name}.conf > /dev/console 2>&1",
        match   => "^stunnel_${name}",
        require => File_line["service ${name}-tun"],
        notify  => Exec['telinit -q'],
      }
    }

    default: {
    }

  }

}
