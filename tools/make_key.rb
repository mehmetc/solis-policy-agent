#!/usr/bin/env ruby
$LOAD_PATH << '.' << '/Users/mehmetc/Dropbox/AllSources/Archiefpunt/services/policy-agent'
#Dir.chdir('..')

require 'json'
require 'jwt'
require 'lib/config_file'


def encode(payload)
  secret = ConfigFile[:secret]
  JWT.encode payload, secret, 'HS512'
end

def decode(payload)
  secret = ConfigFile[:secret]
  JWT.decode(payload, secret, true, {algorithm: 'HS512'}).first
end



exit 1 if ARGV.length != 3
token = encode({"user": ARGV[0], "institution": ARGV[1], "role": ARGV[2].split(',')})
puts token

puts decode(token)