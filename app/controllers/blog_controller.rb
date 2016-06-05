class BlogController < ApplicationController

  def index
    @user = User.find_by(id: session[:user_id])
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    owner = @user.nickname
    repo = @user.blog_repo
    url = "https://api.github.com/repos/#{owner}/#{repo}/contents/_posts"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    @files = JSON.parse(response.body)
  end

  def show
    @post_name = params[:id]
    format = params[:format]
    @user = User.find_by(id: session[:user_id])
    #https://api.github.com/repos/manuraj17/my-test-blog/contents/_posts
    owner = @user.nickname
    repo = @user.blog_repo
    #https://raw.githubusercontent.com/manuraj17/my-test-blog/master/_posts/2016-06-04-welcome-to-jekyll.markdown

    url = "https://raw.githubusercontent.com/#{owner}/#{repo}/master/_posts/#{@post_name}.#{format}"
    puts url
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    @content = response.body
    end
end
