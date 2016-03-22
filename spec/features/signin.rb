require "rails_helper"
require "support/features/signin_helper"

RSpec.describe "User Signin", :type => :feature, :js => true do
  include SigninHelper

  fixtures :users

  context "when valid user credential is given" do
    it "signs in the user" do
      signin("danliu", "danlilu")

      expect(page).to have_content("danliu")
      expect(page).to have_css('a[href="/users/signout"]')
    end
  end
end