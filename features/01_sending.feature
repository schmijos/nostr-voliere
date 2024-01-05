Feature: NIP-01 - Sending events
  As a client
  I want to publish events to the server
  So that the server can pass them on to other clients

  Background:
    Given the client is connected to the relay

  Scenario: Sending a normal kind 1 event
    Given there is an event X
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
    When the client submits event X
    Then the server responds with OK
