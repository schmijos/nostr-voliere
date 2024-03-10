require "minitest/autorun"
require_relative "../lib/filter_cmd"

describe FilterCmd do
  describe "#grep_chain" do
    def assert_grep_chain(filters, expected)
      _(FilterCmd.new(filters).grep_chain).must_equal(expected)
    end

    it "generates command from single filter conditions" do
      assert_grep_chain(
        {"ids" => %w[abc cde]},
        %(grep -F -e '"id":"abc"' -e '"id":"cde"')
      )
    end

    it "generates command from multiple filter conditions" do
      assert_grep_chain(
        {
          "ids" => %w[56dceb906dd5187c53205c34efc3d346008f64d579149e7dbaae8c2077ce1c97 798b52cfd5eae444ef39016f40aa15b3961bcfbaf02b2c18e981ab2b52534226],
          "authors" => %w[1c9dcd8fd2d2fb879d6f02d6cc56aeefd74a9678ae48434b0f0de7a21852f704],
          "kinds" => [1],
          "#p" => %w[f9acb0b034c4c1177e985f14639f317ef0fedee7657c060b146ee790024317ec]
        },
        %(grep -F -e '["p","f9acb0b034c4c1177e985f14639f317ef0fedee7657c060b146ee790024317ec"' | grep -F -e '"pubkey":"1c9dcd8fd2d2fb879d6f02d6cc56aeefd74a9678ae48434b0f0de7a21852f704"' | grep -F -e '"id":"56dceb906dd5187c53205c34efc3d346008f64d579149e7dbaae8c2077ce1c97"' -e '"id":"798b52cfd5eae444ef39016f40aa15b3961bcfbaf02b2c18e981ab2b52534226"' | grep -F -e '"kind":1')
      )
    end
  end

  describe "#head" do
    def assert_head(filters, expected)
      assert_equal(expected, FilterCmd.new(filters).head)
    end

    it "generates default head" do
      assert_head({}, "head -n 100")
    end

    it "generates head from filter" do
      assert_head({"limit" => 99}, "head -n 99")
    end
  end
end
