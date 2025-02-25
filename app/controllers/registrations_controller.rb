class RegistrationsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      login @user
      redirect_to user_path(@user), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end