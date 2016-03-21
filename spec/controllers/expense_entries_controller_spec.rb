require 'rails_helper'

RSpec.describe ExpenseEntriesController, type: :controller do
  describe "GET #create" do
    it "returns http success" do
      get :create_form
      expect(response).to have_http_status(:success)
    end
  end
end
