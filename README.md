## Summary
Provides a defined resource type for managing stunnel on Debian and Red Hat systems.

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
```

## HIERA Usage
Tunnels can be confgured in hiera, at both global and host levels, if tunnes exist at global and host level they merged together and all created
```
stunnel::tuns:
  'global':
     accept: '13306'
     connect: '306'
     certificate: '/etc/stunnel/stunnel.pem'
     chroot: '/var/lib/stunnel4/'
     user: 'stunnel4'
     group: 'stunnel4'
     pid_file: '/global.pid'
     client: false
     sockets:
       - 'l:TCP_NODELAY=1'
       - 'r:TCP_NODELAY=1'
     foreground: false

hosts:
    'server1':
     stunnel::tuns:
       'host':
          accept: 'localhost:873'
          connect: 'remotehost:8873'
          certificate: '/etc/stunnel/stunnel.pem'
          chroot: '/var/lib/stunnel4/'
          user: 'stunnel4'
          group: 'stunnel4'
          pid_file: '/host.pid'
          client: true
          foreground: false
          retry: false
```


## Notes
* There is no sysvinit script installed as part of the `stunnel` package on Red Hat systems.
* Use of SSLv2 is highly discouraged because it's known to be vulnerable.
* The chroot defined in `stunnel::tun` needs to be manually created.

## Authors
* Cody Herriages <cody@puppetlabs.com>
* Sam Kottler <shk@linux.com>
