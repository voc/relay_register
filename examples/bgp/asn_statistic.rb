require 'radix'
require 'ipaddr'
require 'set'
require 'pathname'
require 'thread'

@tree     = Radix.new
@set      = Set.new   # unordered values with no duplicates
@as_count = {}
@as_name  = {}
@work_q   = Queue.new
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
      File.open(file).each_line do |line|
        addr_raw = line.split(' ')[0]
        ip = nil

        if addr_raw =~ /^::ffff.*/
          addr = /(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])/.match(addr_raw).to_s
          ip = IPAddr.new(addr)
        else
          ip = IPAddr.new(addr_raw)
        end

        @work_q.push(ip)
      end

      until @work_q.empty?
        @semaphore.synchronize {
          @set << @work_q.pop
        }
      end
    end
  end

  read_file_threads.each(&:join)
end

ip_tree_thread.join

@set.each do |ip|
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
    key = "#{k}"
    key << ' ' * (longest_asn-k.length)
    key = "#{key} #{@as_name[k]}"
    key << ' ' * (longest_as_name-@as_name[k].length)

    puts "%s %5d %s\n" % [key, @as_count[k], "#" * ((@as_count[k].to_f/count)*500)]
end

puts "%s %5d" % [' ' * (longest_as_name+longest_asn) + ' ', count]
