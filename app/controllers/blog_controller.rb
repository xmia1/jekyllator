require 'kramdown'
require 'yaml'
require 'json'
require 'erb'

class BlogController < ApplicationController

  def index
    user = User.find_by(id: session[:user_id])
    token = session[:token]
    github = Github.new oauth_token: token
    contents = github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
    #contents = Github::Client::Repos::Contents.new oauth_token: token
    #@files = github.repos.list user: @user.nickname
    begin
      @files = contents.get(user.nickname,user.blog_repo, "_posts")
    rescue Github::Error::GithubError => e
      puts e.message
        if e.is_a? Github::Error::ServiceError
          redirect_to home_index_path, :flash => { :error => "Unable to find _posts folder in the selected repo, please select again" }
        elsif e.is_a? Github::Error::ClientError
          # handle client errors e.i. missing required parameter in request
          # Not expecting any client errors here
        end
    end

    @files
    #@files = files
  end

  def show
    #post_name = params[:id]
    #format = params[:format]
    title = "#{params[:id]}.#{params[:format]}"
    @user = User.find_by(id: session[:user_id])
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    owner = @user.nickname
    repo = @user.blog_repo
    #https://raw.githubusercontent.com/manuraj17/my-test-blog/master/_posts/2016-06-04-welcome-to-jekyll.markdown
    #url = "https://raw.githubusercontent.com/#{owner}/#{repo}/master/_posts/#{@post_name}.#{format}"
    #response = GAW.get_post(owner, repo, "#{post_name}.#{format}")
    token = session[:token]
    github = Github.new oauth_token: token
    contents = github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
    @post = Hash.new
    begin
      response = contents.get(@user.nickname, @user.blog_repo, "_posts/#{title}")
      file = Base64.decode64(response.body.content)
      doc = file.force_encoding("utf-8")
      #puts doc
      @post = YAML.load(doc)
      post_content = file.sub(/^\s*---(.*?)---\s/m, "")
      #puts post_content
      c =  Kramdown::Document.new(post_content).to_html
      #puts c
      @post["content"] = c
    rescue Github::Error::GithubError => e
      puts e.message
        if e.is_a? Github::Error::ServiceError
          redirect_to blog_index_path, :flash => { :error => "Unable to find the post" }
        elsif e.is_a? Github::Error::ClientError
          # handle client errors e.i. missing required parameter in request
          # Not expecting any client errors here
        end

    end
#      puts @post
      request.format = 'html'
      respond_to do |format|
        format.html #{ render html: content.html_safe, :layout => true}
        format.json
      end
    #p_doc = Kramdown::Parser::parse(doc)
  end

  def new
  end

  #creating new post
  def create
    post = Hash.new
    title   = params[:title] + ".markdown"
    content = params[:content]
    #format = params[:format]
    #@user = User.find_by(id: session[:user_id])
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    #owner = @user.nickname
    #repo = @user.blog_repo
    @user = User.find_by(id: session[:user_id])
    #authorization_code = params[:authenticity_token]
    #github = Github.new :oauth_token => authorization_code
    token = session[:token]
    #@github = Github.new(oauth_token: token)
    #@github = Github.new(oauth_token: token)
    post = Hash.new
    post["title"] = params[:title]
    post["categories"] = "jekyll"
    post["date"] = Time.now.to_s
    post["content"] = content
    #data = ERB.new(simple_template)
    #{Rails.root}/lib/
    post_template = File.read("#{Rails.root}/lib/post_template.markdown.erb")
    renderer = ERB.new(post_template)

    output = renderer.result(binding)
    #puts output
    contents = Github::Client::Repos::Contents.new oauth_token: token
    path ="/repos/#{@user.nickname}/#{@user.blog_repo}/contents/_posts/#{title }"
    #puts path
    #respone = @github.repos.contents.create @user.nickname, @user.blog_repo, "#{title}",
    #                         path: "#{path}/#{title}",
    #                         content: "#{content}",
    #                         message: "Update from Jekyllator"
    #response = GAW.create_post(owner, repo, post)
    begin
      contents.create @user.nickname,@user.blog_repo , "_posts/#{title}", path: path, message: 'Update from jekyllator', content: output
      redirect_to blog_index_path, :flash => {:success => "Post made"}
    rescue Github::Error::GithubError => e
      redirect_to blog_index_path, :flash => {:error => "Failed to create post"}
    end
  end

  def destroy
    user = User.find_by(id: session[:user_id])
    github = Github.new oauth_token: session[:token]
    contents = github.repos.contents
    title = params[:id] +".markdown"
    #puts title
    path ="/repos/#{user.nickname}/#{user.blog_repo}/contents/_posts/#{title}"

    begin
      file = contents.find user.nickname, user.blog_repo, "_posts/#{title}"
      contents.delete user.nickname, user.blog_repo, "_posts/#{title}", path: path, message: "Removed by Jekyll", sha: file.sha
      redirect_to blog_index_path, :flash => {:success => "Post Deleted"}
    rescue Github::Error::GithubError => e
      redirect_to blog_index_path, :flash => {:error => "Failed to delete post"}
    end

  end

  def edit
    title = "#{params[:id]}.markdown"
    puts title
    @user = User.find_by(id: session[:user_id])
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    owner = @user.nickname
    repo = @user.blog_repo
    #https://raw.githubusercontent.com/manuraj17/my-test-blog/master/_posts/2016-06-04-welcome-to-jekyll.markdown
    #url = "https://raw.githubusercontent.com/#{owner}/#{repo}/master/_posts/#{@post_name}.#{format}"
    #response = GAW.get_post(owner, repo, "#{post_name}.#{format}")
    token = session[:token]
    github = Github.new oauth_token: token
    contents = github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
    @post = Hash.new

    begin
      response = contents.get(@user.nickname, @user.blog_repo, "_posts/#{title}")
      file = Base64.decode64(response.body.content)
      doc = file.force_encoding("utf-8")
      puts "The recived document #{doc}"
      @post = YAML.load(doc)
      post_content = file.sub(/^\s*---(.*?)---\s/m, "")
      puts "File content #{post_content}"
      #c =  Kramdown::Document.new(post_content).to_html
      #puts c
      @post["content"] = post_content
    rescue Github::Error::GithubError => e
      puts e.message
        if e.is_a? Github::Error::ServiceError
          redirect_to blog_index_path, :flash => { :error => "Unable to find the post" }
        elsif e.is_a? Github::Error::ClientError
          # handle client errors e.i. missing required parameter in request
          # Not expecting any client errors here
        end
    end
  end

  def update
    user = User.find_by(id: session[:user_id])
    github = Github.new oauth_token: session[:token]
    contents = github.repos.contents
    title = params[:id] +".markdown"
    path ="/repos/#{user.nickname}/#{user.blog_repo}/contents/_posts/#{title}"
    post = Hash.new
    post["title"] = title
    post["categories"] = "jekyll"
    post["date"] = Time.now.to_s
    post["content"] = params[:content]
    post_template = File.read("#{Rails.root}/lib/post_template.markdown.erb")
    renderer = ERB.new(post_template)
    output = renderer.result(binding)
    begin
      file = contents.find user.nickname, user.blog_repo, "_posts/#{title}"
      #puts file.sha
      contents.update user.nickname, user.blog_repo, "_posts/#{title}", path: path, message: "Update by Jekyll",  content:output,sha: file.sha
      redirect_to blog_path(title), :flash => {:success => "Post Updated"}
    rescue  Github::Error::GithubError => e
      redirect_to blog_index_path, :flash => {:error => "Failed to update post"}
    end


  end

  def parse
    #content = params[:content]
    @doc = Hash.new
    #puts "Text to parse: #{params[:content]}"
    @doc["content"] = Kramdown::Document.new(params[:content],{auto_ids: false}).to_html
    #puts "Text after parse: #{@doc["content"]}"
    respond_to do |format|

      format.json { render json: @doc }
    end
  end

  private

  def set_user_github
    @user = User.find_by(id: session[:user_id])
    @github = Github.new oauth_token: session[:token]
  end
end
