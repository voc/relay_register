class RelayRegister
  class Parser
    class DF
      def self.ordered(string)
        string.split(/\n/).map do |line|
          line unless ignore?(line)
        end.compact
      end

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
