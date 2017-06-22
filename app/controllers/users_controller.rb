class UsersController < ApplicationController
  skip_before_action :require_user_signin,
    only: [:signup_form, :signup, :signin_form, :signin]

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

      redirect_after_user_signin
    else
      @user ||= Account::User.new
      flash.now[:alert] = "Invalid user name or password"

      render "signin_form"
    end
  end

  def change_password
    if !current_user.authenticate(params[:old_password])
      flash.now[:old_password_error] = "Incorrect old password"
    elsif params[:old_password] == params[:new_password]
      current_user.errors.add(:password, :same_as_old_password, :message => "must be different from old password")
    else
      current_user.password = params[:new_password]
      current_user.password_confirmation = params[:new_password_confirmation]
      if current_user.save
        flash.notice = "Your password is updated successfully"
        return redirect_to :back
      end
    end

    render "change_password_form"
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

  def redirect_after_user_signin
    if session[:unauthorized_url]
      original_url = session[:unauthorized_url]
      session[:unauthorized_url] = nil

      redirect_to original_url
    else
      redirect_to root_url
    end
  end
end
