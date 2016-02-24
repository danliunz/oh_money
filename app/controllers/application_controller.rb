class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :set_current_user
  
  private
  
  def set_current_user
    user_id = session[:current_user_id]
    if user_id
      @current_user = User.find_by(id: user_id)
      return if @current_user
    end
    
    user_id = cookies.signed[:remember_me_user_id]
    if user_id
      user = User.find_by(id: user_id)
      if user
        if Security::RandomToken.same?(
            cookies[:remember_me_token], user.remember_me.digest_token
           )
          @current_user = user
        end
      end
    end
  end
end
