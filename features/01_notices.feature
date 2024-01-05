Feature: NIP-01 - Notices
  Background:
    Given the client is connected to the relay

  Scenario Outline: Fuzzy fail
    When the client sends
    """plain
    <string>
    """
    Then the server responds with NOTICE

    Examples:
      | string  |
      | GACH     |
      | ["BLUB"] |
      | {}       |
      | []       |

  Scenario Outline: Failing to parse event
    When the client sends
    """plain
    <json>
    """
    Then the server responds with NOTICE

    Examples:
      | json  |
      | ["EVENT", XXX ] |
