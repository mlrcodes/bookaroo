require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    Mongoid.purge! 
    @email = "john@example.com"
    @user = User.create!(name: "John Doe", email: @email, password: "Secure@Password#123")
  end
  
  test "user_should_be_valid_with_valid_attributes" do
    assert @user.valid?
  end

  test "user_should_have_name" do
    assert_respond_to @user, :name
    assert_equal "John Doe", @user.name
  end
  
  test "user_should_be_invalid_without_name" do
    @user.name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:name], "can't be blank"
  end

  test "user_should_have_email" do
    assert_respond_to @user, :email
    assert_equal "john@example.com", @user.email
  end

  test "user_should_be_invalid_without_email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "user_should_be_invalid_if_email_is_not_unique" do
    user = User.new(name: "John Doe", email: "john@example.com", password: "asd#ASD09")
    assert_not user.valid?, "User should not be valid with non unique email"
  end  

  test "user_should_have_password" do
    assert_respond_to @user, :password
  end  

  test "user_should_be_invalid_without_password" do
    @user.password = nil  
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  test "user_should_be_invalid_with_short_password" do
    @user.password = "a#A2"
    assert_not @user.valid?, "User's password should be invalid if shorter than 8 characters"
  end

  test "user_should_be_invalid_if_password_does_not_have_lower_case_letters" do
    @user.password = "ASD#@$123"
    assert_not @user.valid?, "User's password should be invalid without at least one number"
  end

  test "user_should_be_invalid_if_password_does_not_have_upper_case_letters" do
    @user.password = "asd#@$123"
    assert_not @user.valid?, "User's password should be invalid without at least one number"
  end  

  test "user_should_be_invalid_if_password_does_not_have_numbers" do
    @user.password = "asd#@$ASD"
    assert_not @user.valid?, "User's password should be invalid without at least one number"
  end

  test "user_should_be_invalid_if_password_does_not_have_special_characters" do
    @user.password = "asdASD123"
    assert_not @user.valid?, "User's password should be invalid without at least one special character"
  end  

  test "user_should_be_valid_if_password_is_correct" do
    @user.password = "asd@ASD09"
    assert @user.valid?, "User should be valid with correct password"
  end
end
