require 'rails_helper'


RSpec.describe HomeController, type: :controller do |variable|

  let(:user) { FactoryGirl.create :user}

  before do
    session[:user_id] = user.id
  end

  describe "GET index" do
    it "redirects to blog index path" do
      stub_request(:get, "https://api.github.com/repos/anon/no_repo/contents/_posts").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "[]", :headers => {})

      get :index
      expect(response).to redirect_to(blog_index_path)
    end
  end

  describe "POST create" do
    it "redirects to blog index on valid reporsitory" do

      stub_request(:get, "https://api.github.com/repos/anon/valid_repo_name/contents/_posts").
          with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
          to_return(:status => 200, :body => "", :headers => {})


      params = {
        :repo => "01234|valid_repo_name"
      }
      post :create, params
      expect(response).to redirect_to(blog_index_path)
    end

    it "redirects to home index on invalid repository" do

      stub_request(:get, "https://api.github.com/repos/anon/invalid_repo_name/contents/_posts").with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).to_return(:status => 404, :body => "", :headers => {})


      params = {
        :repo => "01234|invalid_repo_name"
      }
      post :create, params
      expect(response).to redirect_to(home_index_path)

    end

  end


end
