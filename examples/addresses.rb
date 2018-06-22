require "bundler/setup"
require "pa"
require "table_print"

username = ENV.fetch("FORTIOS_USERNAME")
password = ENV.fetch("FORTIOS_PASSWORD")
host = ENV.fetch("FORTIOS_HOST", "localhost")
port = ENV.fetch("FORTIOS_PORT", "9000")

client = Pa::Client.new(
  host: host,
  port: port,
  username: username,
  password: password
)

tp client.addresses, "name", "subnet", "type", "start-ip", "end-ip", "fqdn"

client.close
