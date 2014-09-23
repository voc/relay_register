# encoding: utf-8

require 'json'
require 'base64'
require 'net/http'

uri = URI('http://127.0.0.1:4567/register')

api_key = 'd52b65eaa0654ea7e9e627c7d0357583af25b9b58ea84933f66cfcc2ac9d26146b0b1438702745688dff1e0fd93edaacd57771dd6dd4162d7532b5e6239cb80c'
client  = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path)


data = {
  api_key: api_key,
  data: {
    hostname: `hostname -f`,
    lspci: `lspci`,
    ip_config: `ip a`,
    disk_size: `df -h`,
    memory: `free -m`,
    cpu: File.read('/proc/cpuinfo')
  }
}.to_json

request.content_type = 'application/json'
request.body = data
response = client.request(request)

p response.body
