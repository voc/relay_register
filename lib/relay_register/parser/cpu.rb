class RelayRegister
  class Parser
    class CPU
      def self.count(string)
        count = 0

        string.each_line do |line|
          if line =~ /processor/
            count += 1
          end
        end

        count
      end

      def self.model_name(string)
        model_name = ''

        string.each_line do |line|
          if line =~ /model name/
            model_name = line.split(':').last
          end
        end

        model_name
      end
    end
  end
end
