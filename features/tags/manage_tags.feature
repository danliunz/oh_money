Feature: Tags management
  Users need to manage tags associated with expense entries

  @javascript
  Scenario: user would be able to view list of tags
    Given I sign in as user "danliu"
    And I have created tags "@countdown,@newworld,birthday"
    When I visit the page of listing tags
    Then I should see the first page of listed tages

