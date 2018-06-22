# Pā

> (noun) fortified village, fort, stockade, screen, blockade, city (especially a fortified one).

FortiOS client written in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "pa"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pa

## Usage

If you can reach your FortiOS device directly just provide host, port, username and password.

```ruby
# See examples/addresses.rb
require "bundler/setup"
require "table_print"
require "pa"

client = Pa::Client.new(
  host: "localhost",
  port: 9000,
  username: "admin",
  password: "secret"
)

tp client.addresses, "name", "subnet", "type", "start-ip", "end-ip", "fqdn"

client.close
```

You can also use SSH tunnel, `pa` is using [net-ssh/net-ssh-gateway](https://github.com/net-ssh/net-ssh-gateway) under the hood. You need to provide jumpbox, ssh user, remote host and port. 

```ruby
# See examples/ssh_tunnel.rb
require "bundler/setup"
require "table_print"
require "pa"

client = Pa::Client.new(
  host: "localhost",
  port: 9001,
  username: "admin",
  password: "secret",
  jumpbox: "jumpbox.example.com",
  jumpbox_user: `whoami`.chomp,
  remote_host: "fw.example.com",
  remote_port: 443
)

tp client.addresses, "name", "subnet", "type", "start-ip", "end-ip", "fqdn"

client.close
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/krasio/pa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pa project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pa/blob/master/CODE_OF_CONDUCT.md).
