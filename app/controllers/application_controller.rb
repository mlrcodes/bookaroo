class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private 
  
  def login user
    reset_session
    session[:user_id] = user.id
    Current.user = user
  end
 
  def logout
    reset_session
    Current.user = nil
  end
  
  def authenticate_user!        
    if current_user.nil?
      reset_session
      redirect_to new_session_path, alert: "You must be logged in."
    end
  end

  def current_user
    Current.user ||= User.where(_id: session[:user_id]).first
  end
  helper_method :current_user

  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

end
