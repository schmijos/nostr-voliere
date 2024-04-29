require "json"
require "open3"
require_relative "multi_filter_cmd"

class EventLog
  def initialize(filename = "events.log")
    FileUtils.mkdir_p(File.dirname(filename))
    @file = File.open(filename, "a+")
  end

  def write(event)
    @file.seek(0, IO::SEEK_END)
    @file.write("#{event.to_json}\n")
    @file.flush
  end

  def read_past(filters)
    cmd = "tac #{@file.path} | #{MultiFilterCmd.new(filters).limited_grep} | awk '!seen[$0]++'"
    bigstring = `#{cmd}`
    bigstring.lines.map { |line| JSON.parse(line) }
  end

  # TODO: Opening a new process for each incoming line is bullshit, but I somehow like the idea of using grep filters
  def await_next(filters)
    cmd = MultiFilterCmd.new(filters).line_grep

    @file.seek(0, IO::SEEK_END)
    read_side, write_side = IO.pipe

    pid = Process.spawn(cmd, in: @file, out: write_side)
    # @file.close # Done writing file to the process

    line = read_side.readline
    Process.kill(:INT, pid)
    Process.wait(pid)

    JSON.parse(line)
  end
end
