class FilterCmd
  # @example
  #   FilterCmd.new([
  #     {
  #       "ids" => ["93421380eaff3494b81293eafb0f3bd36c1d54770469a6626085d6597624372a"],
  #       "limit" => 1
  #     }, {
  #       "authors" => ["1c9dcd8fd2d2fb879d6f02d6cc56aeefd74a9678ae48434b0f0de7a21852f704"],
  #       "kinds" => [1],
  #       "#p" => ["f9acb0b034c4c1177e985f14639f317ef0fedee7657c060b146ee790024317ec"],
  #       "limit" => 20
  #     }
  #   ])
  def initialize(filter)
    @limit = 100
    @and_patterns = []

    filter.each do |(key, value)|
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
