require_relative "filter_cmd"

class MultiFilterCmd
  def initialize(filters)
    @filters = filters
  end

  def limited_grep
    filter_cmds = @filters.map do |filter|
      cmd = FilterCmd.new(filter)
      "#{cmd.grep_chain} | #{cmd.head}"
    end
    pipe_union(filter_cmds)
  end

  def line_grep
    filter_cmds = @filters.map do |filter|
      cmd = FilterCmd.new(filter)
      "#{cmd.grep_chain} --line-buffered"
    end
    pipe_union(filter_cmds)
  end

  def pipe_union(cmds)
    %(pee #{cmds.map { "\"#{_1.gsub('"', '\"')}\"" }.join(" ")})
  end
end
