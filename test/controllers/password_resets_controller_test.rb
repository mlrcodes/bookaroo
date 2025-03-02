require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest

  def setup 
    Mongoid.purge!
    @user = User.create!(name: "UserName", email: "example@mail.com", password: PASSWORD_TEST)
  end

  # Password Reset Request
  test "should get new" do
    get new_password_reset_path
    assert_response :success
  end

  test "should enqueue password reset email and create token if email exists" do
    assert_enqueued_emails 1 do
      post password_reset_path, params: { email: @user.email }
    end

    @user.reload
    assert_not_nil @user.reset_password_token
    assert_redirected_to new_session_path
    assert_equal "Check your email to reset your password.", flash[:notice]
  end

  test "should not send email and display error if email does not exist" do
    assert_no_enqueued_emails do
      post password_reset_path, params: { email: "wrong@mail.com" }
    end

    assert_redirected_to new_password_reset_path
    assert_equal "No user for this email was found", flash[:alert]
  end

  # Reset Password Form
  test "should get edit if token is valid" do
    @user.generate_password_reset_token!
    get edit_password_reset_path(token: @user.reset_password_token)
    assert_response :success
  end

  test "should not get edit if token does not exist" do
    get edit_password_reset_path(token: "invalid_token")
    assert_redirected_to new_password_reset_path
    assert_equal "Invalid token, please try again.", flash[:alert]
  end

  test "should not get edit if token is expired" do
    @user.generate_password_reset_token!
    @user.update(reset_password_sent_at: 3.hours.ago) 

    get edit_password_reset_path(token: @user.reset_password_token)
    assert_redirected_to new_password_reset_path
    assert_equal "Reset link has expired.", flash[:alert]
  end

  # Password Update
  test "should update password if token is valid" do
    @user.generate_password_reset_token!
    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: PASSWORD_TEST, password_confirmation: PASSWORD_TEST } }

    @user.reload
    assert @user.authenticate(PASSWORD_TEST)
    assert_nil @user.reset_password_token
    assert_redirected_to new_session_path
    assert_equal "Your password has been reset successfully. Please, login.", flash[:notice]
  end

  test "should not update password if token does not exist" do
    patch password_reset_path(token: "invalid_token"), params: { user: { password: PASSWORD_TEST, password_confirmation: PASSWORD_TEST } }

    assert_redirected_to new_password_reset_path
    assert_equal "Invalid token, please try again.", flash[:alert]
  end

  test "should not update password if token is expired" do
    @user.generate_password_reset_token!
    @user.update(reset_password_sent_at: 3.hours.ago) 

    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: "newpass", password_confirmation: "newpass" } }

    assert_redirected_to new_password_reset_path
    assert_equal "Reset link has expired.", flash[:alert]
  end

  test "should not update password if password is invalid" do
    @user.generate_password_reset_token!
    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: "wrongpass", password_confirmation: "wrongpass" } }

    assert_response :unprocessable_entity
  end

  test "should not update password if it does not match password confirmation" do
    @user.generate_password_reset_token!
    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: PASSWORD_TEST, password_confirmation: PASSWORD_TEST + "wrong" } }

    assert_response :unprocessable_entity
  end

  test "should display error messages if password was not updated" do
    @user.generate_password_reset_token!
    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: "", password_confirmation: "" } }

    assert_response :unprocessable_entity
  end

  test "should clear password reset token after successful reset" do
    @user.generate_password_reset_token!
    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: PASSWORD_TEST, password_confirmation: PASSWORD_TEST } }

    @user.reload
    assert_nil @user.reset_password_token
  end

  test "should not allow using the same reset token twice" do
    @user.generate_password_reset_token!
    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: PASSWORD_TEST, password_confirmation: PASSWORD_TEST } }

    patch password_reset_path(token: @user.reset_password_token), params: { user: { password: PASSWORD_TEST, password_confirmation: PASSWORD_TEST } }

    assert_redirected_to new_password_reset_path
    assert_equal "Invalid token, please try again.", flash[:alert]
  end
end
