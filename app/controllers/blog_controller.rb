require 'kramdown'
require 'yaml'
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
    req = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(req)
    #puts response
    doc = response.body.force_encoding("utf-8")
    @post = YAML.load(doc)
    #post_headers = YAML.load(doc)
    post_content = doc.sub(/^\s*---(.*?)---\s/m, "")


    #doc = "Bob's cat"
    #doc = doc.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => "\'")
    @post["content"] = Kramdown::Document.new(post_content).to_html#.html_safe#.convert#.to_html.html_safe
    #
    puts @post
    request.format = 'html'
    respond_to do |format|
      format.html #{ render html: content.html_safe, :layout => true}
      format.json
    end

    #p_doc = Kramdown::Parser::parse(doc)
    end
end
