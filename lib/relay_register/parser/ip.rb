class RelayRegister
  class Parser
    class IP
      def self.extract_interfaces(string)
        interfaces = {}
        current_interface = nil

        string.split(/\n/).each do |line|
          case line
          when /^\d+:/
            current_interface = line.split(':')[1].strip

            interfaces[current_interface] = {}
            interfaces[current_interface]['ipv4'] = []
            interfaces[current_interface]['ipv6'] = []
          when /inet\s/
            interfaces[current_interface]['ipv4'] << line.split[1]
          when /inet6\s/
            interfaces[current_interface]['ipv6'] << line.split[1]
          else
            next
          end
        end

        interfaces
      end
    end
  end
end
