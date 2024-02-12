require "async/websocket/client"
require "async/http/endpoint"

Given(/^there is an event (.*)$/) do |label, text|
  events[label] = JSON.parse(text)
end

Given(/^the client is connected to the relay$/) do
  @endpoint = Async::HTTP::Endpoint.parse("ws://127.0.0.1:3000")
  @connection = Async::WebSocket::Client.connect(@endpoint)
end

When(/^the client sends$/) do |message|
  @connection.write(message)
end

When(/^the client submits event (.*)$/) do |label|
  @connection.write(["EVENT", events.fetch(label)].to_json)
end

Then(/^the server responds with ([A-Z]+)$/) do |type|
  message = @connection.read
  assert_equal type, JSON.parse(message).first
end

Then(/^the server responds with event (.*)$/) do |label|
  type, _subscription_id, event = JSON.parse(@connection.read)
  assert_equal "EVENT", type
  assert_equal events.fetch(label), event
end

After do
  @connection&.close
end
