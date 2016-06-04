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
      #redirect to list repo files
    end

  end

  def create
    @blog_repo = params[:repo_id]
  end
end
