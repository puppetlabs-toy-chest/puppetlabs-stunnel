## Summary
Provides a defined resource type for managing stunnel on AIX, Debian and Red Hat systems.

## Usage
```
   stunnel::tun { 'rsyncd':
     certificate => "/etc/puppet/ssl/certs/${::clientcert}.pem",
     private_key => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
     ca_file     => '/etc/puppet/ssl/certs/ca.pem',
     crl_file    => '/etc/puppet/ssl/crl.pem',
     chroot      => '/var/lib/stunnel4/rsyncd',
     user        => 'pe-puppet',
     group       => 'pe-puppet',
     client      => false,
     accept      => '1873',
     connect     => '873',
   }

   stunnel::tun { 'ldap':
     ca_file     => '/etc/puppet/ssl/certs/ca.pem',
     crl_file    => '/etc/puppet/ssl/crl.pem',
     client      => true,
     accept      => 'localhost:1389',
     connect     => 'ldap.server.local:636',
   }

```

## Notes
* This includes an sysvinit script because the `stunnel` package on Red Hat systems does not provide one.
* Use of SSLv2 is highly discouraged because it's known to be vulnerable.
* AIX support does not include package installation

## Authors
* Cody Herriages <cody@puppetlabs.com>
* Sam Kottler <shk@linux.com>
* Josh Preston
