class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(email: params[:email], password: params[:password])
    
    if user
      login user
      flash[:notice] = "You have signed in successfully."
      redirect_to user_path user
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end
end
