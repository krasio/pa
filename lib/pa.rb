require "http"
require "pa/version"

module Pa
  class Client
    class Error < RuntimeError; end

    def initialize(host, username, password, http_client: HTTP)
      @host = host
      @username = username
      @password = password
      @http_client = http_client
    end

    def addresses
      resp = get("/api/v2/cmdb/firewall/address")
      JSON.parse(resp.body.to_s)["results"].count
    end

    def get(path)
      authenticated do
        url = build_url(path)
        http_client.headers(
          "Cookie" => http_cookie.cookie_value(cookie_jar.cookies(URI(url))),
          "content-type" => "application/json"
        ).
        get(url, :ssl_context => ssl_context)
      end
    end

    def authenticate
      response = http_client.post(
        build_url("/logincheck"),
        :form => {username: username, secretkey: password, ajax: 1},
        :ssl_context => ssl_context
      )

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

    attr_reader :host, :username, :password, :http_client, :cookie_jar, :ccsrftoken_value

    def http_schema
      "https"
    end

    def http_cookie
      http_client::Cookie
    end

    def ssl_context
      @ssl_context ||= OpenSSL::SSL::SSLContext.new.tap do |ctx|
        ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def build_url(path)
      "#{http_schema}://#{host}#{path}"
    end

    def authenticated(&blk)
      authenticate unless cookie_jar
      blk.call
    end
  end
end
