require 'date'
require 'rails_helper'
require 'timecop'

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

    before do
      Timecop.freeze(Time.local(2016, 6, 8, 10, 3, 10))
    end

    it "returns the show page of the new post" do
      #data = Base64.encode64("---\nlayout: post\ntitle:  asdasdasdasdasd\ndate:   2016-06-08 10:03:10 +0000\ncategories: jekyll\n---\nasdasdasdasdsd")
      puts Time.now
      stub_request(:put, "https://api.github.com/repos/anon/no_repo/contents/_posts/mytitle.markdown").
   with(:body => "{\"path\":\"/repos/anon/no_repo/contents/_posts/mytitle.markdown\",\"message\":\"Update from jekyllator\",\"content\":\"LS0tCmxheW91dDogcG9zdAp0aXRsZTogIG15dGl0bGUKZGF0ZTogICAyMDE2LTA2LTA4IDEwOjAzOjEwICswMDAwCmNhdGVnb3JpZXM6IGpla3lsbAotLS0KYmxhaGJsYWgK\"}",
        :headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
   to_return(:status => 200, :body => "", :headers => {})


      params = {
        :id => "1234",
        :title => "mytitle",
        :content => "blahblah"

      }
      puts Time.now
      post :create, params
      expect(response).to redirect_to blog_index_path
      expect(flash[:success]).to be_present
    end

  end

  describe "delete a post" do

    before do

    end

    it "returns success and redirects to blog index" do

      response_hash = {:sha => "sasdasds"}
      r = response_hash.to_json

      stub_request(:get, "https://api.github.com/repos/anon/no_repo/contents/_posts/testPost.markdown").
   with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
   to_return(:status => 200, :body => r, :headers => {})


      stub_request(:delete, "https://api.github.com/repos/anon/no_repo/contents/_posts/testPost.markdown?message=Removed%20by%20Jekyll&path=/repos/anon/no_repo/contents/_posts/testPost.markdown&sha=sasdasds").
         with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
         to_return(:status => 200, :body => "", :headers => {})

      params = {
        :id => "testPost",
      }
      delete :destroy, params
      expect(response).to redirect_to blog_index_path
      expect(flash[:success]).to be_present
    end


  end


  describe "update a post" do

    it "takes you to edit page" do

      data = Base64.encode64("---\nlayout: post\ntitle:  asdasdasdasdasd\ndate:   2016-06-08 10:03:10 +0000\ncategories: jekyll\n---\nasdasdasdasdsd")
      response_hash = {:content => data}
      r = response_hash.to_json

      stub_request(:get, "https://api.github.com/repos/anon/no_repo/contents/_posts/myTitle.markdown").
         with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
         to_return(:status => 200, :body =>r, :headers => {})

      params = {
        :id => "myTitle",
        :content => "my new content"
      }
      get :edit, params
      response.should render_template :edit
    end

    it "redirects to the blog show page" do

      data = Base64.encode64("---\nlayout: post\ntitle:  asdasdasdasdasd\ndate:   2016-06-08 10:03:10 +0000\ncategories: jekyll\n---\nasdasdasdasdsd")
      response_hash = {:content => data}
      r = response_hash.to_json

            response_hash = {:sha => "sasdasds"}
            r = response_hash.to_json
            stub_request(:put, "https://api.github.com/repos/anon/no_repo/contents/_posts/myTitle.markdown").
                     with(:body => "{\"path\":\"/repos/anon/no_repo/contents/_posts/myTitle.markdown\",\"message\":\"Update by Jekyll\",\"content\":\"LS0tCmxheW91dDogcG9zdAp0aXRsZTogIG15VGl0bGUubWFya2Rvd24KZGF0ZTogICAyMDE2LTA2LTA4IDEwOjAzOjEwICswMDAwCmNhdGVnb3JpZXM6IGpla3lsbAotLS0KCg==\",\"sha\":\"sasdasds\"}",
                          :headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
                     to_return(:status => 200, :body => "", :headers => {})

      stub_request(:get, "https://api.github.com/repos/anon/no_repo/contents/_posts/myTitle.markdown").
           with(:headers => {'Accept'=>'application/vnd.github.v3+json,application/vnd.github.beta+json;q=0.5,application/json;q=0.1', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Github API Ruby Gem 0.14.0'}).
           to_return(:status => 200, :body => r, :headers => {})

      params = {
        :id => "myTitle"
      }
      put :update, params
      title = params[:id]+".markdown"
      expect(response).to redirect_to blog_path(title)
    end

  end

  describe "Posting to the parse endpoint" do
    it "returns the parsed document" do
      params = { :content => "Test string"}

      post :parse, params
      expect(response).to eq("<p>Test string<\\p>")
    end
  end

end
