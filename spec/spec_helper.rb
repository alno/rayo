#Require Rayo files
require File.join(File.dirname(__FILE__), '..', 'lib', 'rayo.rb')

# Require gems
require 'sinatra'
require 'rack/test'
require 'rspec'

# Require support files
Dir[ File.join(File.dirname(__FILE__), 'support', '**', '*.rb') ].each {|f| require f }

# Set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

# Configure RSpec
Rspec.configure do |c|
  c.mock_with :rspec
end
