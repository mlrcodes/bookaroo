require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Mongoid.purge!

    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "MySecurePassword#123",
      password_confirmation: "MySecurePassword#123"
    )
  end

  test "should get new session page" do
    get new_session_url
    assert_response :success
  end

  test "should login with valid credentials" do
    post session_url, params: { email: @user.email, password: "MySecurePassword#123" }
    
    assert_redirected_to user_path @user
    assert_equal "You have signed in successfully.", flash[:notice]
    assert_equal @user.id, session[:user_id], "User should be logged in"
  end

  test "should not login with invalid credentials" do
    post session_url, params: { email: @user.email, password: "wrongpassword" }
    
    assert_response :unprocessable_entity
    assert_equal "Invalid email or password.", flash[:alert]
    assert_nil session[:user_id], "User should not be logged in"
  end
end
