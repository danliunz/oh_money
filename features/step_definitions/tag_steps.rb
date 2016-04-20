Given(/^I have created tags "([^"]*)"$/) do |tags|
  tags.split(",").map(&:strip).each do |tag|
    Tag.create!(name: tag, user: @user)
  end
end

When(/^I visit the page of listing tags$/) do
  visit("/tags/list")
end

Then(/^I should see the first page of listed tages$/) do
  expect(page).to have_content("@countdown")
  expect(page).to have_content("@newworld")
  expect(page).to have_content("birthday")
end