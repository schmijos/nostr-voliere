require "json"
require "open3"
require_relative "filter_cmd"

class EventLog
  def initialize(filename = "events.log")
    FileUtils.mkdir_p(File.dirname(filename))
    @file = File.open(filename, "a")
  end

  def write(event)
    @file.write("#{event.to_json}\n")
    @file.flush
  end

  def read_past(filters)
    cmd = FilterCmd.new(filters)
    bigstring = `tac #{@file.path} | #{cmd.grep_chain} | #{cmd.head}`
    bigstring.lines.map { |line| JSON.parse(line) }
  end

  def await_next(filters)
    cmd = FilterCmd.new(filters)

    # TODO: Opening a new process for each incoming line is bullshit, but I like the idea of using grep filters
    stdin, stdout, process = Open3.popen2(%(tail -n 0 -f #{@file.path} | #{cmd.grep_chain} --line-buffered))
    stdin.close # We don't write to the process

    line = stdout.readline
    Process.kill(:INT, process.pid)
    JSON.parse(line)
  end
end
