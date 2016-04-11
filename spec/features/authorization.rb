require "rails_helper"
require "support/features/signin_helper"

RSpec.describe "User authorization", type: :feature, js: true do
  include SigninHelper

  fixtures :users, :item_types

  it "requires user to signin to access protected url" do
    visit_protected_url

    expect_redirected_to_signin_page
    attemp_signin_with_corrrect_credential

    visit_protected_url
    expect_allow_access_to_protected_url
  end

  it "redirects to originally requestest url once user signs in" do
    visit_protected_url
    expect_redirected_to_signin_page

    attempt_signin_with_wrong_credential
    expect_redirected_to_signin_page

    attemp_signin_with_corrrect_credential
    expect_allow_access_to_protected_url
  end

  it "redirects to signin page with warning if user tries to access other user's page" do
    signin("jennifer", "jennifer")

    wine_of_other_user = item_types(:wine)
    visit "/item_types/#{wine_of_other_user.id}/show"

    expect_redirected_to_signin_page
    expect(all('.alert-danger').at(0).text).to include("Authorization failure")
  end

  private

  def visit_protected_url
    visit "/expense_entries/create"
  end

  def expect_redirected_to_signin_page
    expect(page).to have_current_path("/users/signin")
  end

  def expect_allow_access_to_protected_url
    expect(page).to have_current_path("/expense_entries/create")
  end

  def attemp_signin_with_corrrect_credential
    fill_and_submit_signin_form("danliu", "danliu")
  end

  def attempt_signin_with_wrong_credential
    fill_and_submit_signin_form("danliu", "wrong...")
  end
end
