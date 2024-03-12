require "minitest/autorun"
require_relative "../lib/multi_filter_cmd"

describe MultiFilterCmd do
  describe "#limited_grep" do
    def assert_limited_grep(filters, expected)
      _(MultiFilterCmd.new(filters).limited_grep).must_equal(expected)
    end

    it "generates command from single filter" do
      assert_limited_grep(
        [{
          "ids" => %w[5258688f2d9bb369a01e5066ecd8f349b514a72aa6a1dc2a7ec55c4bac672218],
          "limit" => 42
        }],
        %(pee "grep -F -e '\\"id\\":\\"5258688f2d9bb369a01e5066ecd8f349b514a72aa6a1dc2a7ec55c4bac672218\\"' | head -n 42")
      )
    end

    it "generates command from multiple filters" do
      assert_limited_grep(
        [{
          "ids" => %w[5258688f2d9bb369a01e5066ecd8f349b514a72aa6a1dc2a7ec55c4bac672218],
          "limit" => 1
        }, {
          "ids" => %w[bb5161e991ce907fd671130cee6ca014ca84d18e719efa24e2925815f1ff3c73],
          "limit" => 1
        }],
        %(pee "grep -F -e '\\"id\\":\\"5258688f2d9bb369a01e5066ecd8f349b514a72aa6a1dc2a7ec55c4bac672218\\"' | head -n 1" "grep -F -e '\\"id\\":\\"bb5161e991ce907fd671130cee6ca014ca84d18e719efa24e2925815f1ff3c73\\"' | head -n 1")
      )
    end
  end

  describe "#tail_grep" do
    def assert_line_grep(filters, expected)
      _(MultiFilterCmd.new(filters).line_grep).must_equal(expected)
    end

    it "generates command from single filter" do
      assert_line_grep(
        [{
          "authors" => %w[1c9dcd8fd2d2fb879d6f02d6cc56aeefd74a9678ae48434b0f0de7a21852f704],
          "limit" => 5 # should be ignored
        }],
        %(pee "grep -F -e '\\"pubkey\\":\\"1c9dcd8fd2d2fb879d6f02d6cc56aeefd74a9678ae48434b0f0de7a21852f704\\"' --line-buffered")
      )
    end

    it "generates command from multiple filters" do
      assert_line_grep(
        [{
          "authors" => %w[1c9dcd8fd2d2fb879d6f02d6cc56aeefd74a9678ae48434b0f0de7a21852f704],
          "limit" => 5 # should be ignored
        }, {
          "authors" => %w[96c87765d900b169f5fdd8bc19bf97bd8c6d163ff416a89d45cbb7cac48c9433],
          "limit" => 1 # should be ignored
        }],
        %(pee "grep -F -e '\\"pubkey\\":\\"1c9dcd8fd2d2fb879d6f02d6cc56aeefd74a9678ae48434b0f0de7a21852f704\\"' --line-buffered" "grep -F -e '\\"pubkey\\":\\"96c87765d900b169f5fdd8bc19bf97bd8c6d163ff416a89d45cbb7cac48c9433\\"' --line-buffered")
      )
    end
  end
end
