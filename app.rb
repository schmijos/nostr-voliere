require "async/websocket/adapters/rack"
require "debug"
require_relative "lib/event_log"

class App
  def initialize
    @subscriptions = {} # connection => [subscription_id, …]
    @event_log = EventLog.new
  end

  def call(env)
    Async::WebSocket::Adapters::Rack.open(env, protocols: ["ws"]) do |connection|
      @subscriptions[connection] = Set.new

      render = lambda do |*args|
        connection.write(args.to_json)
        connection.flush
      end

      while (text = connection.read)
        if fuzzy_fail?(text)
          render["NOTICE", "See https://github.com/nostr-protocol/nips/blob/master/01.md"]
          next
        end

        begin
          message = JSON.parse(text)
        rescue JSON::ParserError => error
          render["NOTICE", error.message]
          next
        end

        case message
        in ["EVENT", event]
          record_event(event)
          render["OK", event["id"], true, ""]

        in ["REQ", subscription_id, *filters]
          @subscriptions[connection].add(subscription_id)

          past_events(filters).each do |event|
            render["EVENT", subscription_id, event]
          end
          render["EOSE", subscription_id]

          Async::Task.current.async(subscription_id) do |task, subscription_id|
            while @subscriptions[connection]&.include?(subscription_id)
              render["EVENT", subscription_id, await_inbound_event(filters)]
            end
          rescue
            render["CLOSED", subscription_id, "error: subtask died"]
          end

        in ["CLOSE", subscription_id]
          @subscriptions[connection].delete(subscription_id)
          render["CLOSED", subscription_id, ""]

        else
          render["NOTICE", "See https://github.com/nostr-protocol/nips/blob/master/01.md"]
        end
      end
    rescue
      puts "\e[35mError:\e[0m #{$!}"
      puts $!.backtrace
    ensure
      @subscriptions.delete(connection)
    end or [200, {}, ["WebSocket connections only."]]
  end

  def fuzzy_fail?(message)
    !message.buffer.start_with?(
      /\s*\[\s*"EVENT"\s*,.*/,
      /\s*\[\s*"REQ"\s*,.*/,
      /\s*\[\s*"CLOSE"\s*,.*/
    )
  end

  def record_event(event)
    @event_log.write(event)
  end

  def past_events(filters)
    @event_log.read_past(filters)
  end

  def await_inbound_event(filters)
    @event_log.await_next(filters)
  end
end
