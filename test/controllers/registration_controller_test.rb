require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest

  def setup 
    Mongoid.purge!

    @user_data = {
      user: {
        name: "UserName",
        email: "example@mail.com",
        password: "MySecurePassword#123",
        password_confirmation: "MySecurePassword#123"
      }
    }
  end

  test "should get new" do
    get new_registration_url
    assert_response :success
  end

  test "should create user with valid attributes" do
    assert_difference "User.count", 1 do
      post registration_url, params: @user_data
    end

    assert_redirected_to user_path(User.last)
  end

  test "should log in user after successful registration" do
    post registration_url, params: @user_data

    user = User.last
    assert_equal user.id, session[:user_id] 
  end

  test "should not create user with invalid attributes" do
    assert_no_difference "User.count" do
      post registration_url, params: {
        user: {
          name: "",
          email: "invalidemail",
          password: "pass",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
