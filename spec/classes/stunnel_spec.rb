#!/usr/bin/env rspec
require 'spec_helper'

describe 'stunnel' do
  describe "for operating system family RedHat" do
    it { should_not contain_service("stunnel") }
    it { should contain_package("stunnel") }

    let(:params) {{}}
    let(:facts) {{
      :osfamily => 'redhat'
    }}
  end

  describe "for operating system family Debian" do
    it { should contain_service("stunnel4") }
    it { should contain_package("stunnel4") }

    it { should_not contain_package("stunnel") }
    it { should_not contain_package("stunnel") }
    let(:params) {{}}
    let(:facts) {{
      :osfamily => 'debian',
    }}
  end

  describe "stunnel::tun" do
    it { should include_class("stunnel::params") }
  end

  describe "stunnel::init" do
    it { should include_class("stunnel::params") }
  end
end
