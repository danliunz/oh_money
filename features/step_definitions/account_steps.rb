def register_user(username, password)
  @user = Account::User.create!(name: username, password: password)
end

def sign_in(username, password)
  visit("/users/signin")

  fill_in("user[name]", :with => username)
  fill_in("user[password]", :with => password)
  click_on("Sign in")
end

Given(/^no signed\-up user named "([^"]*)"$/) do |username|
  Account::User.delete_all(name: "diablo")
end

Given(/^a user signed\-up with name "([^"]*)" and password "([^"]*)"$/) do |username, password|
  register_user(username, password)
end

When(/^I attempt sign\-in with name "([^"]*)" and password "([^"]*)"$/) do |username, password|
  sign_in(username, password)
end


When(/^I attempt sign\-in with above name and password "([^"]*)"$/) do |password|
  sign_in(@user.name, password)
end

When(/^I attempt sign\-in with above name and password$/) do
  sign_in(@user.name, @user.password)
end

Then(/^I fail to sign in with invalid username$/) do
  expect(page).to have_content(/invalid user name/i)
  expect(find('input[name="user[name]"]').value).to be_nil
  expect(find('input[name="user[password]"]').value).to be_nil

  expect(page).to have_current_path("/users/signin")
end

Then(/^I fail to sign in with wrong password$/) do
  expect(page).to have_content(/invalid.*password/i)
  expect(find('input[name="user[name]"]').value).to eq(@user.name)
  expect(find('input[name="user[password]"]').value).to be_nil

  expect(page).to have_current_path("/users/signin")
end

Then(/^I sign in successfully$/) do
  expect(page).to have_current_path("/")

  expect(page).to have_content(@user.name)
  expect(page).to have_css('a[href="/users/signout"]')
end

Given(/^I sign in as user "([^"]*)"$/) do |username|
  register_user(username, "password")
  sign_in(username, "password")
end
