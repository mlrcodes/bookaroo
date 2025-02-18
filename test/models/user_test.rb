require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    Mongoid.purge! 

    @user = User.new(name: "John Doe", email: "john.doe@example.com", password: "asd@ASD123")
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  # Name validations
  test "should be invalid without a name" do
    @user.name = ""
    assert_not @user.valid?
    assert_includes @user.errors[:name], "can't be blank"
  end

  test "should be invalid with a short name" do
    @user.name = "A"
    assert_not @user.valid?
    assert_includes @user.errors[:name], "is too short (minimum is 2 characters)"
  end

  test "should be invalid with a long name" do
    @user.name = "A" * 101
    assert_not @user.valid?
    assert_includes @user.errors[:name], "is too long (maximum is 100 characters)"
  end

  test "should be invalid with incorrect name format" do
    @user.name = "John123"
    assert_not @user.valid?
    assert_includes @user.errors[:name], "must be a valid name format"
  end

  # Email validations
  test "should be invalid without an email" do
    @user.email = ""
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should be invalid with incorrect email format" do
    @user.email = "invalid_email"
    assert_not @user.valid?
    assert_includes @user.errors[:email], "must be a valid email format"
  end

  test "should be invalid with duplicate email" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  # Password validations
  test "should be invalid without a password" do
    @user.password = nil
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  test "should be invalid with a short password" do
    @user.password = "A1!a"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "should be invalid with a long password" do
    @user.password = "A1!" + "a" * 22
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too long (maximum is 24 characters)"
  end

  test "should be invalid without an uppercase letter in password" do
    @user.password = "password1!"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "must be a valid password format"
  end

  test "should be invalid without a lowercase letter in password" do
    @user.password = "PASSWORD1!"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "must be a valid password format"
  end

  test "should be invalid without a number in password" do
    @user.password = "Password!"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "must be a valid password format"
  end

  test "should be invalid without a special character in password" do
    @user.password = "Password1"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "must be a valid password format"
  end
end
