Feature: As a Super Admin I will be the only user
  that is able to see & access the Change FEIN Feature.

  Background: Setup site, employer, and benefit application
    Given a CCA site exists with a benefit market
    And there is an employer ABC Widgets
    And this employer has a enrollment_open benefit application
    And this benefit application has a benefit package containing health benefits

  Scenario Outline: HBX Staff with <subrole> subroles should <action> Change FEIN button
    Given that a user with a HBX staff role with <subrole> subrole exists and is logged in
    And the user is on the Employer Index of the Admin Dashboard
    When the user clicks Action for that Employer
    Then the user will <action> the Change FEIN button

    Examples:
      | subrole       | action  |
      | Super Admin   | see     |
      | HBX Staff     | not see |
      | HBX Read Only | not see |
      | Developer     | not see |
      | HBX Tier3     | not see |
