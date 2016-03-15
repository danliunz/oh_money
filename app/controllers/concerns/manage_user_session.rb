module ManageUserSession
  extend ActiveSupport::Concern

  REMEMBER_ME_VALID_DURATION = 7.days

  included do
    before_action :discover_current_user
  end

  def discover_current_user
    @current_user ||= begin
      current_user_in_session || current_user_by_remember_me
    end
  end

  def user_signed_in?
    !!@current_user
  end

  def current_user
    @current_user
  end

  def create_session(user)
    session[:current_user_id] = user.id
    @current_user = user
  end

  def destroy_current_session
    session[:current_user_id] = nil
    forget_user(@current_user.id)

    @current_user = nil
  end

  def remember_user(user)
    secure_token = Security::RandomToken.new
    user.create_remember_me!(digest_token: secure_token.digest)

    cookies.permanent.signed[:remember_me_user_id] = user.id
    cookies.permanent[:remember_me_token] = secure_token.to_s
    cookies.permanent.signed[:remember_me_created_at] = Time.now.to_i
  end

  def forget_user(user_id)
    Account::RememberMe.where(user_id: user_id).delete_all

    cookies.delete(:remember_me_user_id)
    cookies.delete(:remember_me_token)
    cookies.delete(:remember_me_created_at)

    nil
  end

  private

  def current_user_in_session
     user_id = session[:current_user_id]
     Account::User.find_by(id: user_id) if user_id
  end

  def current_user_by_remember_me
    user_id = cookies.signed[:remember_me_user_id]
    if user_id
      if remember_me_expired?
        forget_user(user_id)
      else
       user = Account::User.includes(:remember_me).find_by(id: user_id)
       user if user && remember_me_token_valid?(user)
      end
    end
  end

  def remember_me_expired?
    created_time = cookies.signed[:remember_me_created_at]

    created_time.nil? ||
    Time.at(created_time) <= REMEMBER_ME_VALID_DURATION.ago
  end

  def remember_me_token_valid?(user)
    if user.remember_me
      Security::RandomToken.same?(
        cookies[:remember_me_token], user.remember_me.digest_token
      )
    end
  end
end