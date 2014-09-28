class RelayRegister
  class Parser
    class Free
      # Extract the total memory from `free -m`
      #
      # @param string [String] free -m output
      # @return [String] total memory
      def self.total(string)
        second_row = string.split(/\n/)[1]
        readable_size(second_row.split[1])
      end

      # Convert a given number into MB or GB
      #
      # @param size [String] memory size in MB to convert
      # @retrun [String] normalised size
      def self.readable_size(size)
        size = size.to_f

        case
        when size< 1024.0
          "#{size.round(2)}MB"
        else
          "#{(size/1024).round(2)}GB"
        end
      end
    end
  end
end
