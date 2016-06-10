require 'rails_helper'

RSpec.describe BlogController, type: :controller do

  let(:user) { FactoryGirl.create :user}

  before do
    session[:user_id] = user.id
  end

  describe "GET #index" do

    it "renders the index view" do

      stub_request(:get, "https://api.github.com/repos/anon/no_repo/contents/_posts").with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).to_return(:status => 200, :body => '[{"path": "_posts/2016-06-04-welcome-to-jekyll.markdown"}]', :headers => {})

      get :index
      response.should render_template :index
    end

    it "populates an array of posts" do

      response = '[{ "path": "_posts/2016-06-04-welcome-to-jekyll.markdown" }]'

      stub_request(:get, "https://api.github.com/repos/anon/no_repo/contents/_posts").with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).to_return(:status => 200, :body => response, :headers => {})

      get :index
      expect(JSON.parse(response)).to eq JSON.parse(response)
    end

  end

  describe "GET post #show" do

    it "returns the post content" do

      data = Base64.encode64("---\nlayout: post\ntitle:  asdasdasdasdasd\ndate:   2016-06-08 10:03:10 +0000\ncategories: jekyll\n---\nasdasdasdasdsd")
      response_hash = {:content => data}
      r = response_hash.to_json
      result = {"layout"=>"post", "title"=>"asdasdasdasdasd", "date"=>'2016-06-08 10:03:10.000000000 +0000', "categories"=>"jekyll", "content"=>"<p>asdasdasdasdsd</p>\n"}
      #puts r

      stub_request(:get, "https://api.github.com/repos/anon/no_repo/contents/_posts/1234.markdown").with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).to_return(:status => 200, :body => "#{r}", :headers => {})

      params = {
        :id => "1234",
        :format => "markdown"

      }
      get :show, params
      expect(assigns(:post)).to eq(result)

    end

    it "renders the #show view" do

    end
  end

  describe "create new post" do

    it "returns the show page of the new post" do
      stub_request(:put, "https://api.github.com/repos/anon/no_repo/contents/_posts/mytitle.markdown").
               with(:body => '{"path":"/repos/anon/no_repo/contents/_posts/mytitle.markdown","message":"Update from jekyllator","content":"LS0tCmxheW91dDogcG9zdAp0aXRsZTogIG15dGl0bGUKZGF0ZTogICAyMDE2LTA2LTEwIDA1OjEyOjQ1ICswMDAwCmNhdGVnb3JpZXM6IGpla3lsbAotLS0KYmxhaGJsYWgK"}',
                    :headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
               to_return(:status => 200, :body => "", :headers => {})


      params = {
        :id => "1234",
        :title => "mytitle",
        :content => "blahblah"

      }
      post :create, params
      expect(reponse).to redirect_to blog_index_path
      expect(flash[:success]).to be_present
    end

  end

  describe "delete new post" do

  end


end
