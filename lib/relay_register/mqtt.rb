require 'mqtt'

module RelayRegister::Mqtt do
  def send_message(auth, path, message_humans, message_robots)
    MQTT::Client.connect(

    ) do |client|
      # humans
      client.publish('/voc/alert', message_humans.to_json)
      # robots
      client.publish('/voc/relay/new', message_robots.to_json)
    end
  end

  def convert_message_for_humans(message)
    hash              = {}
    hash['component'] = 'relay/new'
    hash['level']     = 'info'
    hash['msg']       = "New relay #{message['ip']} registered: "\
                        "CPU-Cores: #{message['cpus']}, "\
                        "Network-Interfaces: #{message['interfaces']} - "\
                        "https://c3voc.de/31c3/register/#{message['ip']}"
    hash
  end
end
