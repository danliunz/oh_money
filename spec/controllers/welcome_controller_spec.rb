require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  fixtures :users
  let(:user) { users(:danliu) }
  
  # TODO: move the test case to better place
  describe "GET #index" do
    it "sets current user by remember-me" do
      token = Security::RandomToken.new
      user.create_remember_me!(digest_token: token.digest)
      
      cookies.signed[:remember_me_user_id] = user.id
      cookies[:remember_me_token] = token.to_s
      cookies.signed[:remember_me_created_at] = Time.now.to_i
      
      get :index
      
      expect(assigns[:current_user].id).to eq(user.id)
    end
  end
end
