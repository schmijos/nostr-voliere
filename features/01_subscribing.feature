Feature: NIP-01 - Subscription protocol

  Background:
    Given the client is connected to the relay
    * there is an event A
      """json
      {
        "content": "*For clarity, bulma is older in the art derivative displayed in this nostr thread and merch available.\n\nAssumptions otherwise are self projections\n👻🤷‍♂️",
        "created_at": 1704312028,
        "id": "93421380eaff3494b81293eafb0f3bd36c1d54770469a6626085d6597624372a",
        "kind": 1,
        "pubkey": "ee603283febc4c31b09903392408a2fff1daf69ac2244a5e4ad07eca3bc79dec",
        "sig": "b7c8c402f092ee5aaf0914e9540a72ac1b5a65bd02e11aaab61f899f67094d8e5c3e26d2aae021dfbd33e7cf49234cd1b68a84237f9c9b4547e37eb8206725a3",
        "tags": [
          ["e", "5f764d5fc90b41615242099ffa5285be213a226ac360ab8f332cb9399060a00b", ""],
          ["e", "5df9d4e24a7d19b8aaf951c41a64e80a0394d6fcd4cd629a7c77f5502056f4ba", ""],
          ["p", "958b754a1d3de5b5eca0fe31d2d555f451325f8498a83da1997b7fcd5c39e88c"],
          ["p", "7e2ffb634a5dbc41d36504b0ae78708f137b8c07272d9c91f8a7c900582a4736"]
        ]
      }
      """
    * there is an event B
      """json
      {
        "content": "Looking forward to seeing my man nostr:npub1az9xj85cmxv8e9j9y80lvqp97crsqdu2fpu3srwthd99qfu9qsgstam8y8 in two months. Madeira is going to be absolutely incredible.\nnostr:nevent1qqsft9j5gdgjz47fgee8vht50wsralr06suwuurllm88fdh6jjqlejspz3mhxue69uhhyetvv9ujuerpd46hxtnfdupzp02tz67qsa0ctfqw5y6tqvxhr3d8zkkse6jl2y748n3d66vagnvcqvzqqqqqqymrf2rw",
        "created_at": 1704401954,
        "id": "191795c5ff686a83b86358ab7a8f52651b8375007c2379f6b21d30617868b6c3",
        "kind": 1,
        "pubkey": "3f770d65d3a764a9c5cb503ae123e62ec7598ad035d836e2a810f3877a745b24",
        "sig": "2c786757ae6de86580e55b3611ab1b5bc8dd19ecf3e5431af3b9e7ce5ef96c5649b354e13f4d0e56ae58520783e796dc826dbe91c990c69c453f48a39f6ecace",
        "tags": [
          ["e", "95965443512157c94672765d747ba03efc6fd438ee707ffece74b6fa9481fcca", "", "mention"],
          ["p", "e88a691e98d9987c964521dff60025f60700378a4879180dcbbb4a5027850411", "", "mention"],
          ["p", "bd4b16bc0875f85a40ea134b030d71c5a715ad0cea5f513d53ce2dd699d44d98", "", "mention"]
        ]
      }
      """
    * the client submits event A
    * the client submits event B
    * the server responds with OK
    * the server responds with OK

  Scenario: Requesting events with single filter
    When the client sends
    """json
    ["REQ", "F", {
      "ids": ["93421380eaff3494b81293eafb0f3bd36c1d54770469a6626085d6597624372a"],
      "limit": 1
    }]
    """
    Then the server responds with event A
    And the server responds with EOSE

  Scenario: Overwriting an existing subscription
    Given the client sends
    """json
    ["REQ", "F", {
      "ids": ["93421380eaff3494b81293eafb0f3bd36c1d54770469a6626085d6597624372a"]
    }]
    """
    And the server responds with event A
    And the server responds with EOSE
    When the client sends
    """json
    ["REQ", "F", {
      "ids": ["191795c5ff686a83b86358ab7a8f52651b8375007c2379f6b21d30617868b6c3"]
    }]
    """
    Then the server responds with event B
    And the server responds with EOSE

  Scenario: Stopping a subscription
    When the client sends
    """json
    ["CLOSE", "A"]
    """
    Then the server responds with CLOSED
