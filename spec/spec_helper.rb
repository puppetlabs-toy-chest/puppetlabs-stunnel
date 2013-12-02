dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rubygems'
require 'bundler/setup'
require 'rspec-puppet'

Bundler.require :default, :test

RSpec.configure do |c|
  c.module_path = File.expand_path(File.join(File.dirname(__FILE__), '../../'))
end
