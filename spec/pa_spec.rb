RSpec.describe "Pa::Client" do
  describe "#authenticate" do
    it "returns true on success" do
      http = http_client(body: "1 and rest of the body")
      api_client = Pa::Client.new("localhost", "admin", "secret", http_client: http)

      expect(api_client.authenticate).to be true
    end

    it "raises authentication error on failure" do
      http = http_client(body: "3 and rest of the body")
      api_client = Pa::Client.new("localhost", "admin", "badsecret", http_client: http)

      expect {api_client.authenticate}.to raise_error Pa::Error, %(Authentication failed with: "Two-factor Authentication is needed".)
    end

    it "raises api error on request failure" do
      http = http_client(success: false, status_message: "418 I'm a teapot")
      api_client = Pa::Client.new("localhost", "admin", "badsecret", http_client: http)

      expect {api_client.authenticate}.to raise_error Pa::Error, %(API request failed with: "418 I'm a teapot".)
    end
  end

  def http_client(success: true, body: "", status_message: "200 OK")
    status = double(success?: success, to_s: status_message)
    response = double(status: status, body: body, cookies: :cookie_jar)

    double(post: response)
  end
end
