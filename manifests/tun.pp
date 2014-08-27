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
# [*options*]
#   OpenSSL Library options
#
# [*retry*]
#   reconnect a connect+exec section after it's disconnected
#
# [*sockets*]
#  set socket options
#
# [*foreground*]
#  Should stunnel stay in foreground (don't fork) and log to stderr instead of syslog (unless output is specified).
#
# [*verify*]
#  verify peer certificate, verify levels:
#    0 - Request and ignore peer certificate.
#    1 - Verify peer certificate if present.
#    2 - Verify peer certificate.
#    3 - Verify peer with locally installed certificate.
#    4 - Ignore CA chain and only verify peer certificate.
#    undef - no verify
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
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
define stunnel::tun(
    $certificate,
    $private_key = undef,
    $ca_file = undef,
    $crl_file = undef,
    $ssl_version = 'TLSv1',
    $chroot = undef,
    $user = undef,
    $group = undef,
    $pid_file = undef,
    $debug_level = undef,
    $log_dest = undef,
    $client = false,
    $accept,
    $connect,
    $conf_dir    = $stunnel::params::conf_dir,
    $options = undef,
    $retry = false,
    $foreground = false,
    $sockets  = [],
    $verify = undef,
    $certificate_content = undef,
    $key_content = undef,
    $ca_content = undef,
    $crl_content = undef
) {

  $ssl_version_real = $ssl_version ? {
    'tlsv1' => 'TLSv1',
    'sslv2' => 'SSLv2',
    'sslv3' => 'SSLv3',
    default => $ssl_version,
  }

  $client_on = $client ? {
    true  => 'yes',
    false => 'no',
  }

  $retry_on = $retry ? {
    true  => 'yes',
    false => 'no',
  }
  
  $foreground_on = $foreground ? {
    true  => 'yes',
    false => 'no',
  }



  validate_re($ssl_version_real, '^SSLv2$|^SSLv3$|^TLSv1$', 'The option ssl_version must have a value that is either SSLv2, SSLv3, of TLSv1. The default and prefered option is TLSv1. SSLv2 should be avoided.')


  #if the content of the certificate file is set, generate it
  if ( $certificate_content ) {
    #remove any space characters from the start of each line
    $real_certificate_content = regsubst($certificate_content, '^ ','','G')

    file { $certificate:
      ensure  => file,
      content => $real_certificate_content,
      mode    => '0644',
      owner   => '0',
      group   => '0',
      require => [Package[$stunnel::params::package]],
    }
  }

  #if the content of the private key file is set, generate it
  if (( $key_content ) and ( $private_key )) {
    #remove any space characters from the start of each line
    $real_key_content = regsubst($key_content, '^ ','','G')   
    
    file { $private_key:
      ensure  => file,
      content => $real_key_content,
      mode    => '0644',
      owner   => '0',
      group   => '0',
      require => [Package[$stunnel::package]],
    }
  }
  
   #if the content of the CA file is set, generate it
  if (( $ca_content ) and ( $ca_file )){
    #remove any space characters from the start of each line
    $real_ca_content = regsubst($ca_content, '^ ','','G')  
         
    file { $ca_file:
      ensure  => file,
      content => $real_ca_content,
      mode    => '0644',
      owner   => '0',
      group   => '0',
      require => [Package[$stunnel::package]],
    }
  }

  #if the content of the CRL file is set, generate it
  if (( $crl_content ) and ( $crl_file )) {
    #remove any space characters from the start of each line
    $real_crl_content = regsubst($crl_content, '^ ','','G')   
    
    file { $crl_file:
      ensure  => file,
      content => $real_crl_content,
      mode    => '0644',
      owner   => '0',
      group   => '0',
      require => [Package[$stunnel::package]],
    }
  }

  file { "${conf_dir}/${name}.conf":
    ensure  => file,
    content => template("${module_name}/stunnel.conf.erb"),
    mode    => '0644',
    owner   => '0',
    group   => '0',
    require => File[$conf_dir],
  }

  #define chroot directory only if its not been defined (multiple tunnels via hiera *could* use the same chroot dir) and if its required 
  if ( $chroot ) {
    if ! defined( File[$chroot] ) {
      file { $chroot:
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => '0600',
        require => Package[$stunnel::params::package],
      }
    }
  }

}
