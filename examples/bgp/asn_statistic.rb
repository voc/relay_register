require 'radix'
require 'ipaddr'
require 'set'
require 'pathname'
require 'thread'

IPV4_REGEXP = "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|"\
              "2[0-4][0-9]|[01]?[0-9][0-9]?)\b"

IPV6_REGEXP = "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:)"\
              "{1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]"\
              "{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}"\
              "(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]"\
              "{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|"\
              "[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]"\
              "{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|"\
              "::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}"\
              "[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-"\
              "fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.)"\
              "{3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"

@tree      = Radix.new
@set       = Set.new   # unordered values with no duplicates
@as_count  = {}
@as_name   = {}
@work_q    = Queue.new
@semaphore = Mutex.new

access_files = ARGV.map{|f| Pathname.new(f)}

ip_tree_thread = Thread.new do
  File.open('asn_db.txt', 'r:iso-8859-1').each_line do |line|
    prefix, asn, name = line.split(';')
    name              = name.encode('iso-8859-1').encode('UTF-8').chomp

    # create hash to map as number and name
    @as_name[asn] = name
    # build tree with ip addresses
    @tree.add(prefix)
    @tree[prefix] = { asn: asn, name: name }
  end
end


access_files.each_slice(4) do |file1, file2, file3, file4|
  read_file_threads = []

  [file1, file2, file3, file4].compact.each do |file|
    $stderr.puts file

    read_file_threads << Thread.new do
      i = 0
      File.open(file).each_line do |line|
        i =+ 1

        ip = line[/#{IPV4_REGEXP}/]

        if ip == ''
          ip = line[/#{IPV6_REGEXP}/]
        end

        @work_q.push(ip)

        if i%10000 == 0
          until @work_q.empty?
            @semaphore.synchronize {
              begin
                @set << @work_q.pop(true)
              rescue
                # do nothing
              end
            }
          end
        end
      end

      until @work_q.empty?
        @semaphore.synchronize {
          begin
            @set << @work_q.pop(true)
          rescue
            # do nothing
          end
        }
      end
    end
  end

  read_file_threads.each(&:join)
end

ip_tree_thread.join

puts @set.count

@set.each do |ip|
  next if ip == nil
  subnet = @tree.search_best(ip)
  next if subnet.nil?

  subnet.msg[:asn] == '' ? asn = 'n/a' : asn = subnet.msg[:asn]

  @as_count[asn] = 0 if @as_count[asn].nil?
  @as_count[asn] += 1

end

# calculate sum
count = @as_count.map do |k,v|
  v
end.inject{|sum, x| sum + x}

longest_asn     = @as_count.map{|k,v| k.length }.max
longest_as_name = @as_count.map{|k,v| @as_name[k].length }.max
Hash[@as_count.sort_by{ |k, v| v }].keys.each do |k|
    key = "#{k}#{' ' * (longest_asn-k.length)} #{@as_name[k]}#{' ' * (longest_as_name-@as_name[k].length)}"

    puts "%s %7d %s\n" % [key, @as_count[k], "#" * ((@as_count[k].to_f/count)*500)]
end

puts "%s %7d" % [' ' * (longest_as_name+longest_asn) + ' ', count]
