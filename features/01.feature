Feature: NIP-01
  As a client
  I want to send and receive nostr messages
  So that I can interact with the server

  Background:
    Given a WebSocket connection is established

  Scenario:
    When the client sends EVENT
    Then the server responds with OK
