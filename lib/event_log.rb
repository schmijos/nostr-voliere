class EventLog
  def initialize
    @file = File.open("events.log", "a")
  end

  def write(event)
    @file.write("#{event.to_json}\n")
  end

  def read_past(filters)
    cmd = FilterCmd.new(filters)
    JSON.parse(`tac #{@file.path} | #{cmd.grep_chain} | #{cmd.head}`)
  end

  def read_future(filters)
    cmd = FilterCmd.new(filters)
    JSON.parse(`tail -f #{@file.path} | #{cmd.grep_chain}`)
  end
end
