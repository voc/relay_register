require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
require 'yaml'
require 'json'

require_relative 'models/relay'
require_relative 'lib/relay_register'

register Sinatra::ActiveRecordExtension

set :bind, '127.0.0.1'
set :views,  File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/views/public'
set :config, YAML.load_file(File.dirname(__FILE__) + '/settings.yml')

set :database, {adapter: "sqlite3", database: settings.config['database']}

get '/' do
  @relays = Relay.all
  haml :index
end

post '/register' do
  content_type :json
  # parse body send by client
  data = JSON.parse(request.body.read)

  if api_key_valid?(data['api_key'])
    relay = Relay.find_or_create_by(ip: request.ip)

    relay.hostname = data['data']['hostname']
    relay.ip_config = data['data']['ip_config']
    relay.disk_size = data['data']['disk_size']
    relay.cpu = data['data']['cpu']
    relay.lspci = data['data']['lspci']
    relay.memory = data['data']['memory']
    relay.save

    status 200
  else
    status 401
  end
end

def api_key_valid?(key)
  key == settings.config['api_key'] ? true : false
end
