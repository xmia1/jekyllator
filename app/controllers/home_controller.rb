class HomeController < ApplicationController

  def index
    @user = User.find_by(id: session[:user_id])

    if @user.blog_repo == nil
      url = @user.repo_url
      puts url
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      #user = ENV['FUNCTIONAL_ID']
      #  pw = ENV['FUNCTIONAL_PW']
      #request.basic_auth(user, pw)
      response = http.request(request)
      @repos_hash = JSON.parse(response.body)
      #redirect to select blog
    else
      redirect_to blog_index_path
    end

  end

  def create
    ["_posts"]
    repo = params[:repo]
    repo_details = repo.split("|")
    user  = User.find_by(id: session[:user_id])
    owner = user.nickname
    #checking for _posts folder in the repo
    url = "https://api.github.com/repos/#{owner}/#{repo_details[1]}/contents/_posts"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    #user = ENV['FUNCTIONAL_ID']
    #  pw = ENV['FUNCTIONAL_PW']
    #request.basic_auth(user, pw)
    response = http.request(request)
    response_hash = JSON.parse(response.body)
    @user = User.find_by(id: session[:user_id])

    if response_hash.class.name.eql?("Array")
      if !response_hash[0]["path"].eql?(nil)
        @user.blog_repo = repo_details[1]
        @user.blog_repo_id = repo_details[0]
        @user.save
        redirect_to blog_index_path, notice: "Repo has been selected"
      end
    else
      #format.html {redirect_to engagements_url, :flash => { :error => "Bluegroup creation failed: #{@result["message"]}" }}
      #format.html {redirect_to engagements_url, notice: "Bluegroup #{@result["bluegroup"]} is created with admin ( and member) #{@result["admin"]} "}
      redirect_to home_index_path, :flash => { :error => "Unable to find _posts folder in the selected repo, please select again" }

    end
  end

end
