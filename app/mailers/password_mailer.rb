class PasswordMailer < ApplicationMailer
  def password_reset
    @user = User.where(_id: params[:user_id]).first
    @reset_link = edit_password_reset_url(token: @user.reset_password_token)
    
    mail(to: @user.email, subject: "Reset Your Password")
  end
end
