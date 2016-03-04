When(/^I visit home page$/) do
  visit("/")
end

When(/^I visit home page in a new browser window$/) do
  switch_to_window(open_new_window)
  visit("/")
end

Then(/^I should see name "([^"]*)"$/) do |username|
  expect(page).to have_content(username)
end