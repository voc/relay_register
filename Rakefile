require "./webapp.rb"
require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'

require 'inch/rake'

RSpec::Core::RakeTask.new(:spec)
Inch::Rake::Suggest.new

task :default => [:spec, :inch]
