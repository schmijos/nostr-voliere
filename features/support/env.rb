require "minitest"
require "falcon"
require "async"
require_relative "../../app"

module ServerWorld
  def self.start_server
    @stop_server = false

    @server_thread = Thread.new do
      Async do |task|
        endpoint = Async::HTTP::Endpoint.parse("http://127.0.0.1:3000")
        server = Falcon::Server.new(Falcon::Server.middleware(App.new), endpoint)

        server_task = task.async do
          server.run
        end

        until @stop_server
          task.yield
          sleep 0.1
        end

        server_task.stop
      end
    end
  end

  def self.stop_server
    @stop_server = true
    @server_thread&.join
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

Around do |_scenario, block|
  Async { block.call }
end

