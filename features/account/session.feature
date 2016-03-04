Feature: User session
  Session is created once user signs in

  Scenario: Session is alive in the same browser window
    Given I sign in as user "dragon"
    When I visit home page
    Then I should see name "dragon"

  @javascript
  Scenario: Session is alive in a new browser window
    Given I sign in as user "lizard"
    When I visit home page in a new browser window
    Then I should see name "lizard"
