module SigninHelper
  def signin(username, password)
    visit "/users/signin"

    within("#signin_form") do
      fill_in "Username", with: "danliu"
      fill_in "Password", with: "danliu"
      click_on "Sign in"
    end
  end
end