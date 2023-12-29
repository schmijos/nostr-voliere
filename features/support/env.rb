require "minitest/assertions"
require "falcon"
require "async"
require_relative "../../app"

module ServerWorld
  def start_server
    # Start the server in a separate thread
    @server_thread = Thread.new do
      Async do
        Falcon::Server.new(
          Falcon::Server.middleware(App.new),
          Async::HTTP::Endpoint.parse("http://127.0.0.1:3000")
        ).run.each(&:wait)
      end
    end
    sleep 1  # Give some time for the server to start
  end

  def stop_server
    # Stop the server thread
    @server_thread&.kill
  end
end

World(Minitest::Assertions, ServerWorld)

BeforeAll do
  start_server
end

AfterAll do
  stop_server
end

