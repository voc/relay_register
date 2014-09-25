class RelayRegister
  class Parser
    class CPU
      # Count CPU cores from cpuinfo string
      #
      # @param string [String] /proc/cpuinfo string
      # @return [Fixnum] counted number
      def self.count(string)
        count = 0

        string.split(/\n/).each do |line|
          if line =~ /processor/
            count += 1
          end
        end

        count
      end

      # Extract cpu model name from cpuinfo
      #
      # @param string [String] /proc/cpuinfo string
      # @return [String] cpu model name
      def self.model_name(string)
        model_name = ''

        string.split(/\n/).each do |line|
          if line =~ /model name/
            model_name = line.split(':').last
          end
        end

        # remove spaces
        model_name.strip.gsub(/\s{2,}/, '')
      end
    end
  end
end
