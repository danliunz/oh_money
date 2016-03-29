module SigninHelper
  def signin(username, password)
    visit "/users/signin"
    fill_and_submit_signin_form(username, password)
  end

  def fill_and_submit_signin_form(username, password)
    within("#signin_form") do
      fill_in "Username", with: username
      fill_in "Password", with: password
      click_on "Sign in"
    end
  end
end