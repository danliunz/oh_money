require 'rails_helper'

# TODO: write feature test case to simulate the case
# 1. user signs in with 'remember-me' enabled
# 2. then user signs in again with 'remember-me' disabled
RSpec.describe UsersController, type: :controller do
  describe "GET #signup" do
    it "assigns a new user record" do
      get :signup_form
      expect(assigns[:user]).to be_a_new(User)
    end
    
    it "returns http success" do
      get :signup_form
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "POST #sigin" do
    fixtures :users
    let(:user) { users(:danliu) }
    
    context "when user authentication succeeds" do
      let(:valid_crendential) do
        { user: { name: user.name, password: "danliu" } }
      end
    
      before(:each) do
        post :signin, valid_crendential
      end
      
      it "assigns @user with record from DB" do
        expect(assigns[:user]).not_to be_new_record
        expect(assigns[:user].name).to eq(user.name)
      end
      
      it "creates a user session" do
        expect(session[:current_user_id]).to eq(user.id)
      end
      
      it "redirects to root url" do
        expect(response).to redirect_to(root_url)
      end
      
      context "when remember-me is enabled" do
        let(:valid_crendential) do
          {
            user: { name: user.name, password: "danliu" }, 
            remember_me: "any_value" 
          }
        end
        
        it "stores user id and remember token into cookies" do
          expect(cookies.signed[:remember_me_user_id]).to eq(user.id)
          expect(cookies[:remember_me_token]).not_to be_empty
        end
      end
    end
    
    context "when user authentication fails" do
      def expect_render_signin_form_with_alert
         expect(response).to render_template(:signin_form)
         expect(flash.now[:alert]).to match(/invalid/i)
      end
      
      context "with non-existing username" do
        let(:invalid_credential) do
          { user: { name: "oblivion", password: "do not matter" } }
        end
        
        it "renders signin form with alert" do
          post :signin, invalid_credential
          expect_render_signin_form_with_alert
        end
      end
      
      context "with wrong password" do
        let(:invalid_credential) do
          { user: { name: user.name, password: "wrong!" } }
        end
       
        it "renders signin form with alert" do
          post :signin, invalid_credential
          expect_render_signin_form_with_alert
        end
      end
    end
  end
  
  describe "#signout" do
    fixtures :users
    let(:user) { users(:danliu) }
    let(:valid_crendential) do
      { user: { name: user.name, password: "danliu" } }
    end
      
    before(:each) do 
      post :signin, valid_crendential
      post :signout
    end
    
    it "removes current user id from session" do
      expect(session[:current_user_id]).to be_nil
    end
    
    it "removes remember-me data from cookie" do
      expect(cookies[:remember_me_user_id]).to be_nil
      expect(cookies[:remember_me_token]).to be_nil
    end
    
    it "removes remember-me token from DB" do
      expect(Account::RememberMe.find_by(user: user)).to be_nil
    end
  end
end
