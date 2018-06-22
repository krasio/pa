require "bundler/setup"
require "net/ssh/gateway"
require "byebug"
require "pa"

username = ENV.fetch("FORTIOS_USERNAME")
password = ENV.fetch("FORTIOS_PASSWORD")
host = ENV.fetch("FORTIOS_HOST", "localhost")
port = ENV.fetch("FORTIOS_PORT", "9001")
jumpbox = ENV.fetch("FORTIOS_JUMPBOX")
remote_host = ENV.fetch("FORTIOS_REMOTE_HOST")
ssh_user = `whoami`.chomp

client = Pa::Client.new(
  host: host,
  port: port,
  username:  username,
  password: password,
  jumpbox: "ssh-gateway-wlg2-1",
  jumpbox_user: ssh_user,
  remote_host: "fw-test-wlg2-1",
  remote_port: 443
)

tp client.addresses, "name", "subnet", "type", "start-ip", "end-ip", "fqdn"

client.close
