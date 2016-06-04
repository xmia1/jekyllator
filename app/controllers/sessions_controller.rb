class SessionsController < ApplicationController

  def create
      #puts request.env['omniauth.auth']
      #hash  = request.env["omniauth.auth"]
      #puts hash.to_json
      #puts "*" * 100
      @user = User.from_omniauth(request.env['omniauth.auth'])
      session[:user_id] = @user.id
      puts "Welcome, #{@user.name}!"
      respond_to do |format|
        format.html {redirect_to root_path, :flash => { :success => "Welcome, #{@user.name}!" }}
      end

  end

  def destroy
      session.delete(:user_id)
      @user = nil
      redirect_to root_url, :notice => "Signed out!"
    #session[:user_id] = nil
    #redirect_to root_url, :notice => "Signed out!"
  end

end