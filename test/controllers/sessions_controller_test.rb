require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Mongoid.purge!

    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: PASSWORD_TEST,
      password_confirmation: PASSWORD_TEST
    )
  end

  test "should get new session page" do
    get new_session_url
    assert_response :success
  end

  test "should login with valid credentials" do
    post session_url, params: { email: @user.email, password: PASSWORD_TEST }
    
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

  test "should log out user successfully" do
    # Log in the user
    post session_url, params: { email: @user.email, password: PASSWORD_TEST }
    assert_redirected_to user_path @user
    follow_redirect!
    
    assert_equal @user.id.to_s, session[:user_id], "User should be logged in"

    # Log out the user
    delete session_url
    assert_redirected_to root_path
    follow_redirect!

    # Verify session is cleared
    assert_nil session[:user_id], "Session should be cleared after logout"
    assert_nil Current.user, "Current.user should be reset after logout"

    # Verify logout message is displayed
    assert_match "You have been logged out.", flash[:notice]
  end
end
