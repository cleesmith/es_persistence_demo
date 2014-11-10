class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound do
    render file: "public/404.html", status: 404, layout: false
  end

  def index
    @users = User.all
  end

  def show
    redirect_to users_url
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.auth_token = @user.generate_token
    if @user.save(refresh: true)
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def update
    # bug: these don't trigger validations:
    #  if @user.update(user_params, refresh: true)
    #  if @user.update_attributes(user_params, refresh: true)
    # but the following works:
    @user.attributes = user_params
    if @user.save(refresh: true)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy(refresh: true)
    redirect_to users_url, notice: "User #{@user.username} was deleted."
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end
end
