require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  
  describe "GET #signup" do
    it "assigns a new user record" do
      get :signup_form
      expect(assigns[:user]).to be_new_record
    end
    
    it "returns http success" do
      get :signup_form
      expect(response).to have_http_status(:success)
    end
  end
end
