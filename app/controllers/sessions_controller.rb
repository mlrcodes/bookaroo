class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

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

  def destroy
    logout
    flash[:notice] = "You have been logged out."
    redirect_to root_path
  end
end
