require 'rails_helper'

RSpec.describe SessionsController, type: :controller do |variable|

  describe "GET login" do
    it "redirects to home index path if already logged in" do
    end

    it "redirects to login page if not logged in" do
    end
  end

  describe "GET destroy" do
    it "redirects to root"do
      get :destroy
      expect(response).to redirect_to(root_path)
    end
    it "destroys the session data" do
        expect(session[:user_id]).to eq(nil)
    end
  end

end
