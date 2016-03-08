class UsersController < ApplicationController
  def signup_form
    @user = Account::User.new
  end

  def signup
    @user = Account::User.create(user_params)
    if @user.valid?
      create_session(@user)
      remember_user(@user) if params[:remember_me]

      redirect_to root_url
    else
      render "signup_form"
    end
  end

  def signin_form
    @user = Account::User.new
  end

  def signin
    @user = Account::User.find_by_name(user_params[:name])
    if @user && @user.authenticate(user_params[:password])
      create_session(@user)

      if params[:remember_me]
        remember_user(@user)
      else
        forget_user(@user)
      end

      redirect_to root_url
    else
      @user ||= Account::User.new
      flash.now[:alert] = "Invalid user name or password"

      render "signin_form"
    end
  end

  def signout
    destroy_current_session

    redirect_to root_url
  end

  def show
    @user = Account::User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
