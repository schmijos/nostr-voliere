require 'async/websocket/client'
require 'async/http/endpoint'

Given(/^a WebSocket connection is established$/) do
  Async do
    endpoint = Async::HTTP::Endpoint.parse("http://127.0.0.1:3000")
    @client = Async::WebSocket::Client.connect(endpoint)
  end
end

When(/^the client sends EVENT$/) do
  @client.write(["EVENT", {id: 42}].to_json)
end

Then(/^the server responds with OK$/) do
  response = @client.read
  assert_equal ["OK", 42, true, ""].to_json, response
end
