require File.join(File.dirname(__FILE__), '..', 'lib', 'rayo.rb')

require 'sinatra'
require 'rack/test'
require 'rspec'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

Rspec.configure do |c|
  c.mock_with :rspec
end
