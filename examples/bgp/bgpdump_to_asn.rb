#!/usr/bin/env ruby
# encoding: UTF-8

# Input format provided by bgpdump
# TIME: 10/27/14 16:00:00
# TYPE: TABLE_DUMP_V2/IPV4_UNICAST
# PREFIX: 1.52.176.0/20
# SEQUENCE: 1128
# FROM: 80.249.208.111 AS30132
# ORIGINATED: 10/17/14 14:02:53
# ORIGIN: IGP
# ASPATH: 30132 3491 18403
# NEXT_HOP: 80.249.209.37

prefix, asn, send_prefixes, as_number_to_as_name = '', '', {}, {}

File.open(ARGV[0], 'r:iso-8859-1').each_line do |line|
  match = /^\s*(\d+)\s*(.*)$/.match(line)
  as_number_to_as_name[match[1]] = match[2]
end

while(STDIN.gets)
  case $_
  when /^PREFIX:\s+(.*?)$/
    prefix = $1
  when /^ASPATH:\s(.*?)$/
    plain = $1.gsub(/{|}/, ' ').gsub(',', ' ')
    asn   = plain.split.last
  when /^\s+$/
    unless send_prefixes[prefix]
      puts "#{prefix};#{asn};#{as_number_to_as_name[asn]}"
      send_prefixes[prefix] = true
    end
  else
    next
  end
end

exit 0
