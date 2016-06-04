require 'rails_helper'


RSpec.describe HomeController, type: :controller do |variable|

  let(:user) { FactoryGirl.create :user}

  before do
    session[:user_id] = user.id
  end

  describe "GET index" do
    it "redirects to blog index path" do
      get :index
      expect(response).to redirect_to(blog_index_path)
    end
  end

  describe "POST create" do
    it "redirects to blog index on valid reporsitory" do
      params = {
        :repo => "01234|valid_repo_name"
      }
      post :create, params
      expect(response).to redirect_to(blog_index_path)
    end

    it "redirects to home index on invalid repository" do
      params = {
        :repo => "01234|invalid_repo_name"
      }
      post :create, params
      expect(response).to redirect_to(home_index_path)

    end

  end


end
