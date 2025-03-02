class PasswordResetsController < ApplicationController
  before_action :set_user_by_token, only: [:edit, :update]
  skip_before_action :authenticate_user!

  def new
  end

  def create
    @user = User.where(email: params[:email]).first

    if @user
      @user.generate_password_reset_token!
      PasswordMailer.with(user_id: @user._id).password_reset.deliver_later
      flash[:notice] = "Check your email to reset your password."
      redirect_to new_session_path
    else
      flash[:alert] = "No user for this email was found"
      redirect_to new_password_reset_path
    end
  end

  def edit  
  end

  def update
    if @user.update(password_params)
      @user.clear_password_reset_token!
      flash[:notice] = "Your password has been reset successfully. Please, login."
      redirect_to new_session_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.where(reset_password_token: params[:token]).first

    if !@user.present?
      handle_invalid_token "Invalid token, please try again."
    elsif @user.password_reset_token_expired?
      handle_invalid_token "Reset link has expired."
    end
  end

  def handle_invalid_token message
    flash[:alert] = message
    redirect_to new_password_reset_path
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end  
end
