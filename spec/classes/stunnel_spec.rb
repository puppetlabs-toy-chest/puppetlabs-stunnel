require 'spec_helper'

describe 'stunnel' do
  context 'for operating system family RedHat' do
    let(:params) {{}}
    let(:facts) {{
      :osfamily => 'RedHat',
    }}

    it { is_expected.to_not contain_service('stunnel') }
    it { is_expected.to contain_package('stunnel') }
  end

  context 'for operating system family Debian' do
    let(:params) {{}}
    let(:facts) {{
      :osfamily => 'Debian',
    }}

    it { is_expected.to contain_service('stunnel4') }
    it { is_expected.to contain_package('stunnel4') }

    it { is_expected.to_not contain_package('stunnel') }
    it { is_expected.to_not contain_package('stunnel') }
  end

  context 'stunnel::tun' do
    it { is_expected.to contain_class('stunnel::params') }
  end

  context 'stunnel::init' do
    it { is_expected.to contain_class('stunnel::params') }
  end
end
