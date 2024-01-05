require "minitest"
require "falcon"
require "async"
require_relative "../../app"

module ServerWorld
  def self.start_server
    @server_thread = Thread.new do
      Async do
        Falcon::Server.new(
          Falcon::Server.middleware(App.new),
          Async::HTTP::Endpoint.parse("http://127.0.0.1:3000")
        ).run.each(&:wait)
      end
    end
    sleep 1
  end

  def self.stop_server
    @server_thread&.kill
  end
end

module EventStore
  def events
    @events ||= {}
  end
end

World(Minitest::Assertions, EventStore)

BeforeAll do
  ServerWorld.start_server
end

AfterAll do
  ServerWorld.stop_server
end

