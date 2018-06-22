require "http"
require "pa/version"
require "pa/error"
require "pa/null_ssh_gateway"
require "table_print"

module Pa
  class Client
    def initialize(uri, username, password, http_client: HTTP, jumpbox: nil, jumpbox_user: nil, remote_host: nil, remote_port: 443)
      @uri = URI(uri)
      @username = username
      @password = password
      @http_client = http_client
      @ssh_gateway = build_ssh_gateway(jumpbox, jumpbox_user, remote_host)
      @remote_host = remote_host
      @remote_port = remote_port
    end

    def close
      ssh_gateway.shutdown!
    end

    def addresses
      resp = get("/api/v2/cmdb/firewall/address")
      JSON.parse(resp.body.to_s)["results"]
    end

    def get(path)
      authenticated do
        ssh_gateway.open(remote_host, remote_port, local_port) do |port|
          url = build_url(path, port: port)
          http_client.headers(
            "Cookie" => http_cookie.cookie_value(cookie_jar.cookies(URI(url))),
            "content-type" => "application/json"
          ).
          get(url, :ssl_context => ssl_context)
        end
      end
    end

    def authenticate
      response = ssh_gateway.open(remote_host, remote_port, local_port) do |port|
        http_client.post(
          build_url("/logincheck", port: port),
          :form => {username: username, secretkey: password, ajax: 1},
          :ssl_context => ssl_context
        )
      end

      if response.status.success?
        result = response.body.to_s[0]
        if result == "1"
          @cookie_jar = response.cookies
          true
        else
          authentication_errors = {
            "0" => "Log in failure",
            "2" => "Admin is now locked out",
            "3" => "Two-factor Authentication is needed"
          }
          raise Error.new(%(Authentication failed with: "#{authentication_errors.fetch(result, "Unknown errror")}".))
        end
      else
        raise Error.new(%(API request failed with: "#{response.status.to_s}".))
      end
    end

    private

    attr_reader :uri, :username, :password, :http_client, :cookie_jar, :ccsrftoken_value, :ssh_gateway, :remote_host, :remote_port

    def host
      uri.host
    end

    def local_port
      uri.port
    end

    def scheme
      uri.scheme
    end

    def http_cookie
      http_client::Cookie
    end

    def ssl_context
      @ssl_context ||= OpenSSL::SSL::SSLContext.new.tap do |ctx|
        ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def build_url(path, port: nil)
      host_and_port = [host, (port || local_port)].compact.join(":")
      "#{scheme}://#{host_and_port}#{path}"
    end

    def authenticated(&blk)
      authenticate unless cookie_jar
      blk.call
    end

    def build_ssh_gateway(jumpbox, jumpbox_user, remote_host)
      if jumpbox && jumpbox_user && remote_host
        Net::SSH::Gateway.new(jumpbox, jumpbox_user)
      else
        NullSSHGateway.new(local_port)
      end
    end
  end
end
