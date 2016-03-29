require "rails_helper"
require "support/features/signin_helper"

RSpec.describe "Add expense entry", :type => :feature, :js => true do
  include SigninHelper
  before(:each) { signin("danliu", "danliu") }

  fixtures :users, :item_types, :tags

  context "when valid parameters are given" do
    it "prompts that an expense entry is saved" do
      enter_expense_entry_and_submit_form("wine", 10.5, "@countdown")

      expect(page).to have_content("expense entry for wine is saved")
    end

    it "redirects to a blank form for entering new entry" do
      enter_expense_entry_and_submit_form("wine", 10.5, "@countdown")

      expect(page).to have_current_path("/expense_entries/create")

      expect(all('.text-danger').size).to eq(4)
      all('.text-danger').each do |error_field|
        expect(error_field.text).to be_blank
      end
    end
  end

  context "when no item type is given" do
    it "warns about empty item type" do
      enter_expense_entry_and_submit_form("", 10.5)

      expect(all('.text-danger').at(0).text).not_to be_blank
    end
  end

  context "when no cost is given" do
    it "warns about invalid money" do
      enter_expense_entry_and_submit_form("wine", "")

      expect(all('.text-danger').at(1).text).to include("not valid money")
    end
  end

  context "when no purchase date is given" do
    it "warns about invalid date" do
      enter_expense_entry_and_submit_form("wine", 10.5, "@newworld", false)

      expect(all(".text-danger").at(2).text).to include("not valid date")
    end
  end

  context "when duplicate tags are given" do
    it "fails to save the expense entry" do
      enter_expense_entry_and_submit_form(
        "wine", 30, ["@countdown", "@countdown"]
      )

      expect(find('.alert-danger').text).to include("Fail to save expense entry")
    end
  end
  private

  def enter_expense_entry_and_submit_form(item_type, cost, tags = [], choose_date = true)
    visit "/expense_entries/create"

    fill_in "What", with: item_type
    fill_in "Cost", with: cost

    # click on the 'calendar' icon automatically fills in current date
    find(".glyphicon-calendar").click if choose_date

    Array(tags).each do |tag|
      fill_in "tag_input", with: "@countdown"
      click_on "Add"
    end

    click_on "Submit"
  end
end
