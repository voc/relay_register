require 'sinatra'
require 'haml'
require 'yaml'

set :views,  File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/views/public'
set :config, YAML.load_file(File.dirname(__FILE__) + '/settings.yml')

get '/' do
  haml :index
end

# helper function
def filter_params
  { general: params[:filter], streaming: params[:streaming], idea: params[:idea] }
end
