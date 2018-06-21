require "bundler/setup"
require "pa"

username = ENV.fetch("FORTIOS_USERNAME")
password = ENV.fetch("FORTIOS_PASSWORD")
host = ENV.fetch("FORTIOS_HOST", "localhost:9000")

client = Pa::Client.new(host, username, password)

puts client.addresses
