require "bundler/setup"
require "pa"
require "table_print"

username = ENV.fetch("FORTIOS_USERNAME")
password = ENV.fetch("FORTIOS_PASSWORD")
host = ENV.fetch("FORTIOS_HOST", "https://localhost:9000")

client = Pa::Client.new(host, username, password)

tp client.addresses, "name", "subnet", "type", "start-ip", "end-ip", "fqdn"

client.close
