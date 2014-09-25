# sinatra gems
require 'sinatra'
require 'sinatra/activerecord'
require 'haml'
# stdlib
require 'yaml'
require 'json'
# graph render stuff
require 'graph'
# own libs
require_relative 'models/relay'
require_relative 'lib/relay_register'

register Sinatra::ActiveRecordExtension

set :bind, '127.0.0.1'
set :views,  File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/views/public'
set :config, YAML.load_file(File.dirname(__FILE__) + '/settings.yml')
set :database, {adapter: "sqlite3", database: settings.config['database']}

APP_ROOT = File.expand_path(File.dirname(__FILE__))

# Root
get '/' do
  protected!

  @relays = Relay.all
  haml :index
end

# Manage Relays
get '/relay/:id' do
  protected!

  @relay = Relay.find(params[:id])
  haml :'relay/show'
end

get '/relay/:id/delete' do
  protected!

  @relay = Relay.find(params[:id])
  haml :'relay/delete'
end

delete '/relay/:id' do
  protected!

  relay = Relay.find(params[:id])

  if relay.delete
    redirect to('/')
  else
    status 500
  end
end

get '/relay/:id/edit' do
  protected!

  @relay  = Relay.find(params[:id])
  @relays = Relay.all
  haml :'relay/edit'
end

put '/relay/:id' do
  protected!

  @relay = Relay.find(params[:id])

  if @relay.update_attributes(params[:relay])
    redirect to("relay/#{@relay.id}")
  else
    render :'relay/edit'
  end
end

# Graph
get '/graph' do
  protected!

  build_graph
  haml :graph
end

# Submit new relays
post '/register' do
  content_type :json
  # parse body send by client
  data = JSON.parse(request.body.read)

  if api_key_valid?(data['api_key'])
    new_relay = new_relay?(request.ip, mac = extract_first_interface_mac(data['data']['ip_config']))

    new_relay == true ? relay = Relay.new : relay = new_relay

    relay.ip        = request.ip
    relay.mac       = mac
    relay.hostname  = data['data']['hostname']
    relay.ip_config = data['data']['ip_config']
    relay.disk_size = data['data']['disk_size']
    relay.cpu       = data['data']['cpu']
    relay.lspci     = data['data']['lspci']
    relay.memory    = data['data']['memory']
    relay.save

    # send mqtt message to irc
    send_mqtt_message(relay) if new_relay == true && settings.config['mqtt']['enabled'] != false

    status 200
  else
    status 401
  end
end


# Some useful helper methods
helpers do
  def send_mqtt_message(relay)
    message_humans = generate_message_for_humans(relay)
    message_robots = generate_message_for_robots(relay)

    RelayRegister::Mqtt.send_message({password: settings.config['mqtt']['password'], username: settings.config['mqtt']['username'], remote_host: settings.config['mqtt']['server']},
                                     message_humans,
                                     message_robots)

  end

  def generate_message_for_humans(relay)
    hash              = {}
    hash['component'] = 'relay/new'
    hash['level']     = 'info'
    hash['msg']       = "New relay #{relay.ip} registered: "\
                        "cpu cores: #{relay.cpu_cores}x #{relay.cpu_model_name}, "\
                        "memory: #{relay.total_memory}, "\
                        "disk space: #{relay.free_space}, "\
                        "network interfaces: #{relay.interfaces.count} - "\
                        "https://c3voc.de/31c3/register/relay/#{relay.id}"
    hash
  end

  def generate_message_for_robots(relay)

  end

  def new_relay?(ip, mac)
    relay = Relay.find_by(ip: ip, mac: mac)
    relay.nil? ? true : relay
  end

  def extract_first_interface_mac(ip_a)
    interfaces = RelayRegister::Parser::IP.extract_interfaces(ip_a)
    interfaces.delete('lo')
    interfaces[interfaces.keys[0]]['mac']
  end

  def api_key_valid?(key)
    key == settings.config['api_key'] ? true : false
  end

  def build_graph
    digraph do
      Relay.where('master != ""').each do |r|
        master = Relay.find(r.master)
        black << node(r.hostname) << edge(master.hostname, r.hostname)
      end
       # black << node("live.dus") << edge("live.ber", "live.dus")
       # black << node("live.dus") << edge("live.het", "live.dus")
       # black << node("live.het") << edge("live.man", "live.het")
       save(File.join(APP_ROOT, 'views', 'public', 'images', 'graph'), 'png')
    end
  end

  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    user = settings.config['basic_auth']['user']
    password = settings.config['basic_auth']['password']

    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [user, password]
  end
end
