require 'rails_helper'

RSpec.describe BlogController, type: :controller do

  let(:user) { FactoryGirl.create :user}

  before do
    session[:user_id] = user.id
  end

  describe "GET index" do

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

  end

  describe "GET view post" do
    it "returns http success" do
      params= {
        :id => "a_post"
      }
      get :show, params
      expect(response).to have_http_status(:success)
    end
  end
end
