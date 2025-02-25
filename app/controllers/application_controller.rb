class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private 
  
  def login(user)
    Current.user = user
    reset_session
    session[:user_id] = user.id
  end
end
