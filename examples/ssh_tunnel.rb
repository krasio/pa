require "bundler/setup"
require "net/ssh/gateway"
require "byebug"
require "pa"

username = ENV.fetch("FORTIOS_USERNAME")
password = ENV.fetch("FORTIOS_PASSWORD")
host = ENV.fetch("FORTIOS_HOST", "https://localhost:9001")
jumpbox = ENV.fetch("FORTIOS_JUMPBOX")
remote_host = ENV.fetch("FORTIOS_REMOTE_HOST")
ssh_user = `whoami`.chomp

client = Pa::Client.new(host, username, password,
                        jumpbox: jumpbox,
                        jumpbox_user: ssh_user,
                        remote_host: remote_host,
                        remote_port: 443
                       )

tp client.addresses, "name", "subnet", "type", "start-ip", "end-ip", "fqdn"

client.close
