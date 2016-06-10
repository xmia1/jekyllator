class SessionsController < ApplicationController

  before_action :github

  def login
    @user = User.find_by(id: session[:user_id])
    if !@user.nil?
      redirect_to home_index_path
    end
  end

  def create
      #puts request.env['omniauth.auth']
      #hash  = request.env["omniauth.auth"]
      #puts hash.to_json
      #puts "*" * 100
      #authorization_code = params[:code]
      #access_token = @github.get_token authorization_code
      #puts access_token.token   # => returns token value
      token = env["omniauth.auth"].credentials.token
      session[:token] = token
      #@githubGithub.new client_id: ENV['GITHUB_KEY'], client_secret: ENV['GITHUB_SECRET']
      @user = User.from_omniauth(request.env['omniauth.auth'])
      #@github.scopes.list
      #response =  @github.repos.list user: @user.nickname
      #puts @github.scopes.list
      #respone = @github.repos.contents.create @user.nickname, @user.blog_repo, 'hello.rb',
      #                         path: 'hello.rb',
      #                         content: "puts 'hello ruby'",
      #                         message: "my commit"
      #puts response.body
      #session[:github] = @github
      session[:user_id] = @user.id
      puts "Welcome, #{@user.name}!"
      respond_to do |format|
        format.html {redirect_to home_index_path, :flash => { :success => "Welcome, #{@user.name}!" }}
      end

  end

  def destroy
      session.delete(:user_id)
      @user = nil
      redirect_to root_url, :notice => "Signed out!"
    #session[:user_id] = nil
    #redirect_to root_url, :notice => "Signed out!"
  end

  private

   def github
     @github ||= Github.new client_id: ENV['GITHUB_KEY'], client_secret: ENV['GITHUB_SECRET']
    end

end
