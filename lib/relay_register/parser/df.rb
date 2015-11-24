class RelayRegister
  class Parser
    class DF
      # Extract and normalise `df -h` output
      #
      # @param string [String] df -h output
      # @return [Hash] with all mountpoints as keys
      def self.extract_df(string)
        disk_free = {}

        string.split(/\n/).each do |line|
          next if ignore?(line)

          splitted_line = line.split
          mount_point   = splitted_line.last

          disk_free[mount_point] = {}
          disk_free[mount_point]['size_total']     = splitted_line[1]
          disk_free[mount_point]['size_used']      = splitted_line[2]
          disk_free[mount_point]['size_available'] = splitted_line[3]
        end

        disk_free
      end

      protected

      # Check if a given mountpoint should be ignored or not
      #
      # @param string [String] line to check
      # @return [Boolean] shows that a given mountpoint or dive should be
      #                   ignored
      def self.ignore?(string)
        if string =~ /Filesystem|^dev|shm$|cgroup$|run$|\/run/
          true
        else
          false
        end
      end
    end
  end
end
