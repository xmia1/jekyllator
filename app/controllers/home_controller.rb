require 'github_api'
class HomeController < ApplicationController


  def new
  end

  def index
    @user = User.find_by(id: session[:user_id])

    if @user.blog_repo == nil
      authorization_code = params[:authenticity_token]
      github = Github.new :oauth_token => authorization_code
      @repos = github.repos.list user: @user.nickname
    else
      redirect_to blog_index_path
    end

  end

  #selecting the blog repo
  def create
    repo_data = params[:repo]
    repo_details_array = repo_data.split("|")
    user = User.find_by(id: session[:user_id])
    token = session[:token]
    #github = Github.new oauth_token: token
    #contents = github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
    contents = Github::Client::Repos::Contents.new oauth_token: token
    begin
      response = contents.get(user.nickname, repo_details_array[1], "_posts")
      user.blog_repo     = repo_details_array[1]
      user.blog_repo_id  = repo_details_array[0]
      user.save
      redirect_to blog_index_path, notice: "Repo has been selected"
    rescue Github::Error::GithubError => e
      puts e.message
        if e.is_a? Github::Error::ServiceError
          redirect_to home_index_path, :flash => { :error => "Unable to find _posts folder in the selected repo, please select again" }
        elsif e.is_a? Github::Error::ClientError
          # handle client errors e.i. missing required parameter in request
          # Not expecting any client errors here
        end
    end

  end

end
