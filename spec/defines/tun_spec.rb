require 'spec_helper'

describe 'stunnel::tun' do
  context 'no verify' do
    let(:pre_condition){ 'include stunnel' }
    let(:title){ 'rsyncd' }
    let(:params) do
      {
        'chroot'  => '/var/lib/stunnel4/rsyncd',
        'user'    => 'pe-puppet',
        'group'   => 'pe-puppet',
        'client'  => true,
        'accept'  => '1873',
        'connect' => '873',
        'verify'  => 'default',
      }
    end
    it {
      is_expected.to contain_file('/etc/stunnel/rsyncd.conf')
        .with_content(/verify = default/)
    }
  end

  context 'verify' do
    let(:pre_condition){ 'include stunnel' }
    let(:title){ 'rsyncd' }
    let(:params) do
      {
        'certificate' => '/etc/puppet/ssl/certs/clientcert.pem',
        'private_key' => '/etc/puppet/ssl/private_keys/clientcert.pem',
        'ca_file'     => '/etc/puppet/ssl/certs/ca.pem',
        'crl_file'    => '/etc/puppet/ssl/crl.pem',
        'client'      => false,
        'verify'      => '2',
        'chroot'      => '/var/lib/stunnel4/rsyncd',
        'user'        => 'pe-puppet',
        'group'       => 'pe-puppet',
        'accept'      => '1873',
        'connect'     => '873',
      }
    end
    it {
      is_expected.to contain_file('/etc/stunnel/rsyncd.conf')
        .with_content(/cert =.*verify = 2/m)
    }
  end
end
