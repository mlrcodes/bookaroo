require "test_helper"

class UserTest < Minitest::Test
  def setup
    Mongoid.purge! 

    @user = User.create!(name: "John Doe", email: "john@example.com", password: "password123")
  end
  
  def test_user_is_valid_with_valid_attributes
    assert @user.valid?
  end

  def test_user_has_name
    assert_respond_to @user, :name
    assert_equal "John Doe", @user.name
  end
  
  # def test_user_requires_name
  #   @user.name = nil
  #   assert_not @user.valid?
  #   assert_includes @user.errors[:name], "can't be blank"
  # end

  def test_user_has_email
    assert_respond_to @user, :email
    assert_equal "john@example.com", @user.email
  end

  # def test_user_requires_email
  #   @user.email = nil
  #   assert_not @user.valid?
  #   assert_includes @user.errors[:email], "can't be blank"
  # end

  def test_user_has_password
    assert_respond_to @user, :password
  end  

  # def test_user_requires_password
  #   @user.password = nil  
  #   assert_not @user.valid?
  #   assert_includes @user.errors[:password], "can't be blank"
  # end
end
