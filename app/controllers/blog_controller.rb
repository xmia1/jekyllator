require 'kramdown'
require 'yaml'
require 'json'
require 'erb'

class BlogController < ApplicationController

  before_action :set_user_github

  def index
    contents = @github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
    begin
      @files = contents.get(@user.nickname,@user.blog_repo, "_posts")
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
    #title = "#{params[:id]}.#{params[:format]}"
    title = "#{params[:id]}.markdown"
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    owner = @user.nickname
    repo = @user.blog_repo
    #https://raw.githubusercontent.com/manuraj17/my-test-blog/master/_posts/2016-06-04-welcome-to-jekyll.markdown
    contents = @github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
    @post = Hash.new
    begin
      response = contents.get(@user.nickname, @user.blog_repo, "_posts/#{title}")
      file = Base64.decode64(response.body.content)
      doc = file.force_encoding("utf-8")
      @post = YAML.load(doc)
      post_content = file.sub(/^\s*---(.*?)---\s/m, "")
      c =  Kramdown::Document.new(post_content).to_html
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
      request.format = 'html'
      respond_to do |format|
        format.html #{ render html: content.html_safe, :layout => true}
        format.json
      end
  end

  def new
  end

  #creating new post
  def create
    post = Hash.new
    title   = params[:title] + ".markdown"
    content = params[:content]
    post = Hash[
      "title"       =>  params[:title],
      "categories"  =>  "jekyll",
      "date"        =>  Time.now.to_s,
      "content"     =>  content
    ]
    #data = ERB.new(simple_template)
    post_template = File.read("#{Rails.root}/lib/post_template.markdown.erb")
    renderer = ERB.new(post_template)

    output = renderer.result(binding)
    contents =  @github.repos.contents#Github::Client::Repos::Contents.new oauth_token: token
    path ="/repos/#{@user.nickname}/#{@user.blog_repo}/contents/_posts/#{title }"
    #puts path
    begin
      contents.create @user.nickname,@user.blog_repo , "_posts/#{title}", path: path, message: 'Update from jekyllator', content: output
      redirect_to blog_index_path, :flash => {:success => "Post made"}
    rescue Github::Error::GithubError => e
      redirect_to blog_index_path, :flash => {:error => "Failed to create post"}
    end
  end

  def destroy
    contents = @github.repos.contents
    title = params[:id] +".markdown"
    path ="/repos/#{@user.nickname}/#{@user.blog_repo}/contents/_posts/#{title}"

    begin
      file = contents.find @user.nickname, @user.blog_repo, "_posts/#{title}"
      contents.delete @user.nickname, @user.blog_repo, "_posts/#{title}", path: path, message: "Removed by Jekyll", sha: file.sha
      redirect_to blog_index_path, :flash => {:success => "Post Deleted"}
    rescue Github::Error::GithubError => e
      redirect_to blog_index_path, :flash => {:error => "Failed to delete post"}
    end

  end

  def edit
    title = "#{params[:id]}.markdown"
    puts title
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    owner = @user.nickname
    repo = @user.blog_repo
    #https://raw.githubusercontent.com/manuraj17/my-test-blog/master/_posts/2016-06-04-welcome-to-jekyll.markdown
    contents = @github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
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
    contents = @github.repos.contents
    title = params[:id] +".markdown"
    path ="/repos/#{@user.nickname}/#{@user.blog_repo}/contents/_posts/#{title}"
    post = Hash[
      "title"       =>  title,
      "categories"  =>  "jekyll",
      "date"        =>  Time.now.to_s,
      "content"     =>  params[:content]
    ]

    post_template = File.read("#{Rails.root}/lib/post_template.markdown.erb")
    renderer = ERB.new(post_template)
    output = renderer.result(binding)
    begin
      file = contents.find @user.nickname, @user.blog_repo, "_posts/#{title}"
      contents.update @user.nickname, @user.blog_repo, "_posts/#{title}", path: path, message: "Update by Jekyll",  content:output,sha: file.sha
      redirect_to blog_path(title), :flash => {:success => "Post Updated"}
    rescue  Github::Error::GithubError => e
      redirect_to blog_index_path, :flash => {:error => "Failed to update post"}
    end


  end

  def parse
    @doc = Hash.new
    @doc["content"] = Kramdown::Document.new(params[:content],{auto_ids: false}).to_html
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
