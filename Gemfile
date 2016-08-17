source 'https://rubygems.org'

group :tests do
  gem 'puppetlabs_spec_helper', :require => false
end

group :system_tests do
  gem 'beaker',       :require => false
  gem 'beaker-rspec', :require => false
  gem 'beaker-puppet_install_helper', :require => false
end

gem 'facter'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

gem 'pry'
