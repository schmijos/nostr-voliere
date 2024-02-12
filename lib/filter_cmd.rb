class FilterCmd
  def initialize(filters)
    @limit = 100
    @range = []
    @and_patterns = []

    filters.each do |key, value|
      case key
      when "ids"
        @and_patterns.prepend value.map { |id| %("id":"#{id}") }
      when "authors"
        @and_patterns.prepend value.map { |pubkey| %("pubkey":"#{pubkey}") }
      when "kinds"
        @and_patterns.append value.map { |kind| %("kind":#{kind.to_i}) }
      when /#\w/
        @and_patterns.prepend value.map { |tag_value| %(["#{key[1..]}","#{tag_value}") }
      when "since"
        # @range[0] = %("created_at":#{value})
      when "until"
        # @range[1] = %("created_at":#{value})
      when "limit"
        @limit = value.to_i
      else
        puts "Unknown filter: #{key}"
      end
    end
  end

  def grep_chain
    @and_patterns.map do |or_patterns|
      grep_args = or_patterns.map { |pattern| "-e '%s'" % pattern }
      "grep -F #{grep_args.join(" ")}"
    end.join(" | ")
  end

  def head
    "head -n #{@limit}"
  end
end
