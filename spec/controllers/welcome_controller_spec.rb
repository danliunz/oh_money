require 'rails_helper'

# Rationale: considering session/cookie access is impossible
# in non-rack based test in Cucumber/Capybara, we choose to
# verify remember-me in some controller test which we can manipulate
# cookie easily
RSpec.describe WelcomeController, type: :controller do
  fixtures :users
  let(:user) { users(:danliu) }

  describe "GET #index" do
    render_views

    def simulate_remember_me_present
      token = Security::RandomToken.new
      user.create_remember_me!(digest_token: token.digest)

      cookies.signed[:remember_me_user_id] = user.id
      cookies[:remember_me_token] = token.to_s
      cookies.signed[:remember_me_created_at] = Time.now.to_i
    end

    it "discovers current user by remember-me" do
      simulate_remember_me_present
      expect(session[:current_user_id]).to be_nil

      get :index


      expect(assigns[:current_user].id).to eq(user.id)
      expect(controller.user_signed_in?).to be true
    end
  end
end
