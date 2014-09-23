class RelayRegister
  class Parser
    class Free
      def self.total(string)
        second_row = string.split(/\n/)[1]
        readable_size(second_row.split[1])
      end

      def self.readable_size(size)
        size = size.to_f
        case size
          when size < 1024
            "#{size} MB" % size
          else
            "#{(size/1024).round(2)} GB"
        end
      end
    end
  end
end
