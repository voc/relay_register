# First include simplecov to track code coverage
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'rspec'
require 'rack/test'
require 'sinatra'
require 'haml'

%w{}.each do |file|
  require File.join(File.dirname(__FILE__), '..', 'lib', "#{file}.rb")
end

require File.join(File.dirname(__FILE__), '..', 'webapp.rb')

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.color = true
  config.order = 'random'

  # Create fake webserver to send serve all request local
  config.before(:each) do
    project_root = File.expand_path('..', __FILE__)
  end
end

def app
  Sinatra::Application
end
