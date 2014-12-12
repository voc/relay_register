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
require_relative 'models/bandwith'
require_relative 'models/subnet_tree'
require_relative 'models/tag'
require_relative 'lib/relay_register'

register Sinatra::ActiveRecordExtension

if development?
  set :config, YAML.load_file(File.dirname(__FILE__) + '/settings.yml.example')
else
  set :config, YAML.load_file(File.dirname(__FILE__) + '/settings.yml')
end

set :bind, '127.0.0.1'
set :views,  File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/views/public'
set :database, { adapter: "sqlite3", database: settings.config['database'] }
set :subnet_tree, SubnetTree.new(settings.config['asn_db'])

APP_ROOT = File.expand_path(File.dirname(__FILE__))

disable :show_exceptions
disable :raise_errors

error do
  if request.request_method == 'GET'
    protected!

    @error = request.env['sinatra.error']
    haml :'500'
  else
    status 500
  end
end

# Root
get '/' do
  protected!

  @subnet_tree   = settings.subnet_tree
  @relays        = sorting_relays
  @public_relays = Relay.where(public: true)
  @group         = true if params[:group]

  sum = 0
  @public_relays.each do |relay|
    sum += relay.measured_bandwith.to_f if relay.measured_bandwith
  end

  @measured_bandwith = sum

  haml :index
end

get '/ipaddresses' do
  protected!

  v4 = []
  v6 = []
  Relay.all.each do |relay|
    relay.ips.each do |ip|
      if ip.ipv6?
        v6 << "'#{relay.hostname.chomp}': '#{ip.to_s}'"
      else
        next if [IPAddr.new("10.0.0.0/8"),
                 IPAddr.new("172.16.0.0/12"),
                 IPAddr.new("192.168.0.0/16")].any? {|i| i.include? ip}
        v4 << "'#{relay.hostname.chomp}': '#{ip.to_s}'"
      end
    end
  end

  [ v4 + v6 ].join(",<br>")
end

# Manage Relays
get '/relay/:id' do
  protected!

  @relay       = Relay.find(params[:id])
  @subnet_tree = settings.subnet_tree
  if @relay.bandwiths.count != 0
    @relay_bw = Hash[@relay.bandwiths.group_by{ |r| r.created_at }.sort_by{ |k, v| k }]
  end

  haml :'relay/show'
end

# Manage Relays
get '/relay/:id/bandwith' do
  protected!

  @relay       = Relay.find(params[:id])
  @subnet_tree = settings.subnet_tree
  if @relay.bandwiths.count != 0
    @relay_bw = Hash[@relay.bandwiths.group_by{ |r| r.created_at }.sort_by{ |k, v| k }.reverse]
  end

  haml :'relay/bandwith'
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

  p params

  if @relay.update_attributes(params[:relay]) && update_tags(@relay, params[:tags])
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
  data = parse_request_body(request.body.read)

  if api_key_valid?(data['api_key'])
    # test present relay in database
    new_relay = new_relay?(request.ip, mac = extract_first_interface_mac(data['raw_data']['ip_config']))

    new_relay == true ? relay = Relay.new : relay = new_relay

    relay.ip        = request.ip
    relay.mac       = mac
    relay.hostname  = data['raw_data']['hostname']
    relay.ip_config = data['raw_data']['ip_config']
    relay.disk_size = data['raw_data']['disk_size']
    relay.cpu       = data['raw_data']['cpu']
    relay.lspci     = data['raw_data']['lspci']
    relay.memory    = data['raw_data']['memory']
    relay.save

    # send mqtt message to irc
    send_mqtt_message(relay) if new_relay == true && settings.config['mqtt']['enabled'] != false

    status 200
  else
    status 401
  end
end

post '/register/bandwith' do
  content_type :json
  data = parse_request_body(request.body.read)

  if api_key_valid?(data['api_key']) && data['raw_data']['measures'] != nil
    relay = new_relay?(request.ip, mac = extract_first_interface_mac(data['raw_data']['ip_config']))

    # Create new bw entry for each pf destination
    data['raw_data']['measures']['single_destinations'].each do |dest, iperf|
      Bandwith.create(
        relay: relay,
        iperf: iperf,
        destination: dest,
        created_at: Time.at(data['raw_data']['time'])
      )
    end

    # Create bw parallel test item
    md = data['raw_data']['measures']['multiple_destinations']
    Bandwith.create(
      relay: relay,
      iperf: md['iperf'],
      at_the_same_time: true,
      destination: md['destinations'].join(','),
      created_at: Time.at(data['raw_data']['time'])
    )

    status 200
  else
    status 401
  end
end

get '/settings' do
  protected!

  @settings = settings.config
  haml :settings
end

# Some useful helper methods
helpers do
  # Take http POST request body, encrypts data and return json data.
  #
  # @param request_body [String] http post request body
  # @return [JSON] parsed body as json
  def parse_request_body(request_body)
    # parse body send by client
    body = JSON.parse(request_body)
    # try to decrypt data
    begin
      decrypted_data = RelayRegister::AES.decrypt(body['data'], settings.config['encryption_key'], body['iv'])
    rescue
      status 510
      return
    end

    JSON.parse(decrypted_data)
  end

  def send_mqtt_message(relay)
    message_humans = RelayRegister::Mqtt.generate_message_for_humans(relay)
    message_robots = RelayRegister::Mqtt.generate_message_for_robots(relay)

    RelayRegister::Mqtt.send_message({password: settings.config['mqtt']['password'], username: settings.config['mqtt']['username'], remote_host: settings.config['mqtt']['server']},
                                     message_humans,
                                     message_robots)

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
    digraph 'streaming cdn' do
      Relay.all.each do |relay|
        case relay.public
        when true
          color = green
        when false
          color = red
        else
          color = black
        end

        if relay.master == ''
          color << node("#{relay.hostname} - #{relay.tags.map(&:name).join(',')}")
        else
          master = Relay.find(relay.master)
          color << node("#{relay.hostname} - #{relay.tags.map(&:name).join(',')}") << edge("#{master.hostname} - #{master.tags.map(&:name).join(',')}", "#{relay.hostname} - #{relay.tags.map(&:name).join(',')}")
        end
      end

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

  def sorting_relays
    case params[:sort]
    when 'pbl'      then Relay.order(:public)
    when 'hostname' then Relay.order(:hostname)
    when 'master'   then Relay.order(:master)
    when 'memory'   then Relay.all.sort_by{ |o, e| o.total_memory <=> o.total_memory }
    when 'bw'       then Relay.order(measured_bandwith: :desc)
    else
      Relay.order(:public)
    end
  end

  def update_tags(relay, tags)
    p tags
    tags.each do |key, value|
      case value
      when /true/
        relay.tags << Tag.find(key)
      else
        relay.tags.delete(Tag.find(key))
      end
    end
  end
end
