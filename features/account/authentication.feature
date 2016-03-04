Feature: User Sign-in
  Only registered user can sign in with valid credential

  Scenario: User fails to sign in with invalid username
    Given no signed-up user named "diablo"
    When I attempt sign-in with name "diablo" and password "whatever"
    Then I fail to sign in with invalid username
  
  Scenario: User fails to sign in with wrong password
    Given a user signed-up with name "powershop" and password "awesome"
    When I attempt sign-in with above name and password "wrong"
    Then I fail to sign in with wrong password
    
  Scenario: User signs in successfully with valid credential
    Given a user signed-up with name "powershop" and password "awesome"
    When I attempt sign-in with above name and password
    Then I sign in successfully