require 'kramdown'
require 'yaml'
require 'json'
require 'erb'

class BlogController < ApplicationController

  before_action :set_user_github

  def index
    # Fetching the repo list from github
    contents = @github.repos.contents #(@user.nickname, @user.blog_repo, "_posts/")
    begin
      # Fetching all the files in the '_posts' foder.
      @files = contents.get(@user.nickname,@user.blog_repo, "_posts")
    rescue Github::Error::GithubError => e
      puts e.message
        # This error denots that the folder does not exist
        if e.is_a? Github::Error::ServiceError
          redirect_to home_index_path,
                      :flash => {
                        :error => "Unable to find _posts folder in the selected
                                   repo, please select again"
                      }
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
    # preparing the title of the post to be fetched. The posts are stored in
    # markdown format, hence the extension needs to be appended.
    title = "#{params[:id]}.markdown"

    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    # The owner of the repo - nickname of the current signed in user
    owner = @user.nickname
    # The repo from which content has to be fetched - the blog repo which is
    # saved for the user, in the DB.
    repo = @user.blog_repo

    #https://raw.githubusercontent.com/manuraj17/my-test-blog/master/_posts/2016-06-04-welcome-to-jekyll.markdown

    # Creating an instance object for contents
    contents = @github.repos.contents#(@user.nickname, @user.blog_repo, "_posts/")
    @post = Hash.new
    begin
      # Fetching the contents of the file
      response = contents.get(@user.nickname, @user.blog_repo, "_posts/#{title}")

      # The conents fetched will be Base64 encoded
      file = Base64.decode64(response.body.content)

      # Forcing some encoding for escape characters etc.
      doc = file.force_encoding("utf-8")

      # The file is basically a YAML document, so retrieving it in proper format
      @post = YAML.load(doc)

      # Parsing through regext to get the ppost content
      post_content = file.sub(/^\s*---(.*?)---\s/m, "")

      # Parsing the content through Kramdown to get the formatted content
      c =  Kramdown::Document.new(post_content).to_html

      # Saving it to the object
      @post["content"] = c
    rescue Github::Error::GithubError => e
      puts e.message
        if e.is_a? Github::Error::ServiceError
          redirect_to blog_index_path, :flash => {
            :error => "Unable to find the post"
          }
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
    contents =  @github.repos.contents
    #Github::Client::Repos::Contents.new oauth_token: token
    path ="/repos/#{@user.nickname}/#{@user.blog_repo}/contents/_posts/#{title }"
    #puts path
    begin
      contents.create @user.nickname,@user.blog_repo , "_posts/#{title}",
       path: path, message: 'Update from jekyllator', content: output
      redirect_to blog_index_path, :flash => {:success => "Post made"}
    rescue Github::Error::GithubError => e
      redirect_to blog_index_path, :flash => {:error => "Failed to create post,
       Error: #{e}"}
    end
  end

  def destroy
    # Initializing content object
    contents = @github.repos.contents

    # Prepping the title
    title = params[:id] +".markdown"

    # Building the path where the posts exist
    path ="/repos/#{@user.nickname}/#{@user.blog_repo}/contents/_posts/#{title}"

    begin
      # Find the exact post
      file = contents.find @user.nickname, @user.blog_repo, "_posts/#{title}"

      # Deleting it, the delete method arguments are explained in the github API
      contents.delete @user.nickname,
                      @user.blog_repo,
                      "_posts/#{title}",
                      path: path,
                      message: "Removed by Jekyll",
                      sha: file.sha

      redirect_to blog_index_path, :flash => {:success => "Post Deleted"}
    rescue Github::Error::GithubError => e

      redirect_to blog_index_path,
                  :flash => {
                    :error => "Failed to delete post. Error: #{e}"
                  }
    end

  end

  def edit
    # Prepping the title
    title = "#{params[:id]}.markdown"
    #puts title
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    #
    #owner = @user.nickname
    #repo = @user.blog_repo
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
      redirect_to blog_index_path, :flash => {:error => "Failed to update post. Erorr: #{e}"}
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
