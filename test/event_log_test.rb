require "minitest/autorun"
require "async"
require_relative "../lib/event_log"

describe EventLog do
  describe "#write" do
    before do
      @log = EventLog.new("tmp/test.log")
    end

    after do
      @log.instance_variable_get(:@file).close
      File.delete("tmp/test.log")
    end

    it "writes event to file" do
      event = {
        content: "*For clarity, bulma is older in the art derivative displayed in this nostr thread and merch available.\n\nAssumptions otherwise are self projections\n👻🤷‍♂️",
        created_at: 1704312028,
        id: "93421380eaff3494b81293eafb0f3bd36c1d54770469a6626085d6597624372a",
        kind: 1,
        pubkey: "ee603283febc4c31b09903392408a2fff1daf69ac2244a5e4ad07eca3bc79dec",
        sig: "b7c8c402f092ee5aaf0914e9540a72ac1b5a65bd02e11aaab61f899f67094d8e5c3e26d2aae021dfbd33e7cf49234cd1b68a84237f9c9b4547e37eb8206725a3",
        tags: [
          ["e", "5f764d5fc90b41615242099ffa5285be213a226ac360ab8f332cb9399060a00b", ""],
          ["e", "5df9d4e24a7d19b8aaf951c41a64e80a0394d6fcd4cd629a7c77f5502056f4ba", ""],
          ["p", "958b754a1d3de5b5eca0fe31d2d555f451325f8498a83da1997b7fcd5c39e88c"],
          ["p", "7e2ffb634a5dbc41d36504b0ae78708f137b8c07272d9c91f8a7c900582a4736"]
        ]
      }

      @log.write(event)

      assert_equal(<<~JSON, File.read("tmp/test.log"))
        {"content":"*For clarity, bulma is older in the art derivative displayed in this nostr thread and merch available.\\n\\nAssumptions otherwise are self projections\\n👻🤷‍♂️","created_at":1704312028,"id":"93421380eaff3494b81293eafb0f3bd36c1d54770469a6626085d6597624372a","kind":1,"pubkey":"ee603283febc4c31b09903392408a2fff1daf69ac2244a5e4ad07eca3bc79dec","sig":"b7c8c402f092ee5aaf0914e9540a72ac1b5a65bd02e11aaab61f899f67094d8e5c3e26d2aae021dfbd33e7cf49234cd1b68a84237f9c9b4547e37eb8206725a3","tags":[["e","5f764d5fc90b41615242099ffa5285be213a226ac360ab8f332cb9399060a00b",""],["e","5df9d4e24a7d19b8aaf951c41a64e80a0394d6fcd4cd629a7c77f5502056f4ba",""],["p","958b754a1d3de5b5eca0fe31d2d555f451325f8498a83da1997b7fcd5c39e88c"],["p","7e2ffb634a5dbc41d36504b0ae78708f137b8c07272d9c91f8a7c900582a4736"]]}
      JSON
    end
  end

  describe "#read_past" do
    before do
      @log = EventLog.new("test/data/milano_events.log")
    end

    after do
      @log.instance_variable_get(:@file).close
    end

    it "reads past events" do
      events = @log.read_past({"ids" => %w[ba3508cb615d9ca6743a6afb26d16834abaeb319a5acaa601b8e51aa0dacb65d]})
      assert_equal(1, events.length)
      assert_equal("ba3508cb615d9ca6743a6afb26d16834abaeb319a5acaa601b8e51aa0dacb65d", events[0]["id"])
    end
  end

  describe "#read_future" do
    before do
      @log = EventLog.new("tmp/test.log")
    end

    after do
      @log.instance_variable_get(:@file).close
      File.delete("tmp/test.log")
    end

    it "reads future events" do
      Sync do
        inbound_event = Async do
          @log.await_next({"ids" => %w[44a1c4ba076a44c7bd53a9a876c9b5fc168dfcf5633d5692106940ecdf5ee7ab]})
        end

        File.write("tmp/test.log", <<~JSON, mode: "a")
          {"content":"So far.. :D","created_at":1706037874,"id":"0d88ebe0cfe945ccb026e735b782437ff258dff17308dca99f4670dad8eb64b0","kind":1,"pubkey":"42828f49b8b80a56abf547dfcf51738ccb2fb76dcc8e703b8f4b11947228068a","sig":"13830ef461ce55fd9d856a0680c01e95c3d6118a9156d6538b965879fc60dfcf288955879633a25ae26cbaa301c9cba3ba0f0585db2b9d8ec4caae8ad9e34d60","tags":[["e","683bfc10c0d39ef0a8270521e99e020719b73bc98535764e48c9f2ca0ac3d496","","root"],["e","715b0c720300dcb4f98a2dd89ea3522dfda5023eb1cdd055c513b4b04aec75c5"],["e","dd2f57c1c1618a0ce3fb08e83993045c20b86a86c83e91e71e0d95c700267b25"],["e","a1b0a6988603f92b6b610caa06c3c67d3fe931c0a095d5ce29b1ce5b73127148","","reply"],["p","80caa3337d33760ee355697260af0a038ae6a82e6d0b195c7db3c7d02eb394ee"],["p","42828f49b8b80a56abf547dfcf51738ccb2fb76dcc8e703b8f4b11947228068a"],["p","0689df5847a8d3376892da29622d7c0fdc1ef1958f4bc4471d90966aa1eca9f2"]]}
          {"content":"Hallo! Bin neu hier und sammel erstmal etwas hilflos deutschsprachiges in meinem Feed.","created_at":1706037041,"id":"44a1c4ba076a44c7bd53a9a876c9b5fc168dfcf5633d5692106940ecdf5ee7ab","kind":1,"pubkey":"0d3a0ef3b11776987c32566d0077745d201ca0fe0fae26e893e43904640be679","sig":"7b1fe528094012ab18ba97f89f7847127b82894304e6d3dc581039c70ac89b5a1bbb74fe7605e3dd1b5c730232d888b67fcaad65495cb070972aed44f65d42fb","tags":[]}
          {"content":"Use an npub to tag someone","created_at":1706041860,"id":"b1833693f162598250e98740f19b750fbcd65a15e774e351b2cb0aa344fe3e6c","kind":1,"pubkey":"269b0b280b99e4724daf5718a6c8e412c59269cc472a70b472b1acf0dec91bca","sig":"d46318abec82aa3aac717a430092c0908df23fead59480643d9f82a7d7d69751cfdf759f7b292638f53e8717481af7ea241a40e1fb43a7c3577df874675de282","tags":[["e","8bd345bf09ee91ec70c0ac3a775dac10eee0c23aad5019b661410f2ecb5e048a","","root"],["e","cfa797ac21fe40bd71333a6791c6e398dfc4592eaf8f145df659bc84ca4ee13e","","reply"],["p","d61f3bc5b3eb4400efdae6169a5c17cabf3246b514361de939ce4a1a0da6ef4a"],["p","a7684f58f7a8b99f2c02ef6263d07995ee7fbaf88a7fd1a6bd877979bb0a8456"]]}
        JSON

        assert_equal("Hallo!", inbound_event.wait["content"][0..5])
      end
    end
  end
end
