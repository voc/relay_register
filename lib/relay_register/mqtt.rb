require 'mqtt'

class RelayRegister
  class Mqtt
    def self.send_message(auth, message_humans, message_robots)
      MQTT::Client.connect(
        remote_host: auth[:remote_host],
        username: auth[:username],
        password: auth[:password]
      ) do |client|
        client.publish('/voc/alert', message_humans.to_json)
      end
    end
  end
end
