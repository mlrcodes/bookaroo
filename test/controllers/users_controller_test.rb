require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Mongoid.purge!
    
    @password = "MySecurePassword#123"
    @user = User.new(name: "UserName", email: "example@mail.com", password: @password)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: { email: @user.email, name: @user.name, password: @password } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    @user.save!
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    @user.save!
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    @user.save!

    patch user_url(@user), params: { user: { email: @user.email, name: @user.name, password: @password } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    @user.save!

    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
