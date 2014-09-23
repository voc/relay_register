require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'yaml'

require_relative 'models/relay'

register Sinatra::ActiveRecordExtension

set :views,  File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/views/public'
set :config, YAML.load_file(File.dirname(__FILE__) + '/settings.yml')

set :database, {adapter: "sqlite3", database: settings.config['database']}

get '/' do
  haml :index
end
