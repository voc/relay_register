require 'ipaddr'
require 'radix'

db = Radix.new

File.open(ARGV[0], 'r:iso-8859-1').each_line.each_slice(10000) do |slice|
  slice.each do |line|
    data = line.split(';')

    db.add(data[0])
    db[data[0]] = {asn: data[1], name: data[2]}
  end

  if net = db.search_best(ARGV[1])
    puts net.msg[:name]
    exit
  end
end
