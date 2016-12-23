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

    # Generate mqtt message for humanes
    #
    # @param relay [Relay] new relay
    # @return [Hash] mqtt message
    def self.generate_message_for_humans(url_base, relay)
      hash              = {}
      hash['component'] = 'relay/new'
      hash['level']     = 'info'
      hash['msg']       = "New relay #{relay.ip} registered: "\
                          "cpu cores: #{relay.cpu_cores}x #{relay.cpu_model_name}, "\
                          "memory: #{relay.total_memory}, "\
                          "disk space: #{relay.free_space}, "\
                          "network interfaces: #{relay.interfaces.count} - "\
                          + url_base + relay.id.to_s
      hash
    end

    # Generate mqtt message optimised for robots
    #
    # @param relay [Relay] new relay
    # @return [Hash] mqtt message
    def self.generate_message_for_robots(relay)
      # pending
    end
  end
end
