require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Mongoid.purge!
    @newPassword = "NewSecurePassword#123"
    @user = User.create!(name: "UserName", email: "example@mail.com", password: PASSWORD_TEST)

    post session_url, params: { email: @user.email, password: PASSWORD_TEST }
    follow_redirect!    
  end

  test "should get edit password form" do
    get edit_password_url
    assert_response :success
  end

  test "should update password if all fields are valid" do
    patch password_url, params: {
      user: {
        password_challenge: PASSWORD_TEST,
        password: @newPassword,
        password_confirmation: @newPassword
      }
    }
        
    assert_redirected_to edit_password_path
    follow_redirect!
    assert_select "div", "Your password has been updated successfully."
  end

  test "should not update password if current password is not correct" do
    patch password_url, params: {
      user: {
        password_challenge: "wrongPassword#123",
        password: @newPassword,
        password_confirmation: @newPassword
      }
    }
    
    assert_response :unprocessable_entity
    assert @user.reload.authenticate(PASSWORD_TEST)
  end

  test "should not update password if current password is missing" do
    patch password_url, params: {
      user: {
        password: @newPassword,
        password_confirmation: @newPassword
      }
    }

    assert_response :unprocessable_entity
    assert @user.reload.authenticate(PASSWORD_TEST)
  end

  test "should not update password if new password is invalid" do
    invalid_password = "invalidpassword"
    patch password_url, params: {
      user: {
        password_challenge: PASSWORD_TEST,
        password: invalid_password,
        password_confirmation: invalid_password
      }
      
    }
    
    assert_response :unprocessable_entity
    assert @user.reload.authenticate(PASSWORD_TEST)
  end

  test "should not update password if pasword and confirm password do not match" do
    patch password_url, params: {
      user: {
        password_challenge: PASSWORD_TEST,
        password: @newPassword,
        password_confirmation: "notMatchingPassword#123"
      }
    }

    assert_response :unprocessable_entity
    assert @user.reload.authenticate(PASSWORD_TEST)
  end
end
