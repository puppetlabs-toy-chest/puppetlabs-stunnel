## Summary
Provides a defined resource type for managing stunnel on Debian and Red Hat systems.

## Usage
```
   stunnel::tun { 'rsyncd':
     certificate   => "/etc/puppet/ssl/certs/${::clientcert}.pem",
     private_key   => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
     ca_file       => '/etc/puppet/ssl/certs/ca.pem',
     crl_file      => '/etc/puppet/ssl/crl.pem',
     chroot        => '/var/lib/stunnel4/rsyncd',
     user          => 'pe-puppet',
     group         => 'pe-puppet',
     client        => false,
     accept        => '1873',
     connect       => '873',
    verify         => '2',
    retry          => false,
    foreground     => false,
    ssl_options    => 'DONT_INSERT_EMPTY_FRAGMENTS',
    socket_options => ['l:TCP_NODELAY=1','r:TCP_NODELAY=1'],
    fips           => false,
   }
```

## Notes
* There is no sysvinit script installed as part of the `stunnel` package on Red Hat systems.
* Use of SSLv2 is highly discouraged because it's known to be vulnerable.
* The chroot defined in `stunnel::tun` needs to be manually created.

## Authors
* Cody Herriages <cody@puppetlabs.com>
* Sam Kottler <shk@linux.com>
