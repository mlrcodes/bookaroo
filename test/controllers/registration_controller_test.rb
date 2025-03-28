require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest

  def setup 
    Mongoid.purge!

    @user_data = {
      user: {
        name: "UserName",
        email: "example@mail.com",
        password: PASSWORD_TEST,
        password_confirmation: PASSWORD_TEST
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

    assert_redirected_to user_path User.last
  end

  test "should log in user after successful registration" do
    post registration_url, params: @user_data

    user = User.last
    assert_equal user.id, session[:user_id] 
  end

  test "should not create user with invalid name" do
    assert_no_difference "User.count" do
      post registration_url, params: {
        user: {
          name: "1nv4l1d",
          email: "example@mail.com",
          password: PASSWORD_TEST,
          password_confirmation: PASSWORD_TEST
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with invalid email" do
    assert_no_difference "User.count" do
      post registration_url, params: {
        user: {
          name: "User Name",
          email: "invalidemail",
          password: PASSWORD_TEST,
          password_confirmation: PASSWORD_TEST
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not create user with blank password fields" do
    assert_no_difference "User.count" do
      post registration_url, params: {
        user: {
          name: "User Name",
          email: "example@mail.com",
          password: "",
          password_confirmation: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
