class SessionsController < ApplicationController
  layout 'sessions'

  def new
  end

  def create
    user = User.find_by_username(params[:username])
    # note: user.authenticate is from ActiveModel::SecurePassword:
    if user && user.authenticate(params[:password])
      cookies[:auth_token] = user.auth_token
      redirect_to root_url
    else
      flash.now.alert = "Invalid username or password"
      render "new"
    end
  end

  def destroy
    session[:ref] = nil
    cookies.delete(:auth_token)
    redirect_to login_url, :notice => "Logged out!"
  end
end
