class UsersController < ApplicationController
  def signup_form
    @user = User.new
  end
  
  def signup
    @user = User.create(user_params)
    if @user.valid?
      create_user_session
      redirect_to root_url
    else
      render "signup_form"
    end
  end
  
  def signin_form
    @user = User.new
  end
  
  def signin
    @user = User.find_by_name(user_params[:name])
    if @user && @user.authenticate(user_params[:password])
      create_user_session
      redirect_to root_url
    else
      @user ||= User.new
      flash.now[:alert] = "Invalid user name or password"
      
      render "signin_form"
    end
  end
  
  def signout
    destroy_user_session
    redirect_to root_url
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
  
  def create_user_session
    session[:current_user_id] = @user.id
  end
  
  def destroy_user_session
    @_current_user = (session[:current_user_id] = nil)
  end
end
