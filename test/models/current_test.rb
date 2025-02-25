require "test_helper"

class CurrentTest < ActiveSupport::TestCase

  def setup 
    Mongoid.purge!

    @user = User.new(name: "UserName", email: "example@mail.com", password: "MySecurePassword#123")
    @user2 = User.new(name: "SecondUserName", email: "example2@mail.com", password: "MySecurePassword#123")
  end

  test "should set and get current user" do
    @user.save!

    Current.user = @user
    assert_equal @user, Current.user
  end

  test "should reset current user after request lifecycle" do
    @user.save!
    
    Current.user =  @user
    assert_equal  @user, Current.user

    Current.reset
    assert_nil Current.user
  end

  test "should isolate Current attributes between threads" do
    @user.save!
    @user2.save!

    thread1 = Thread.new do
      Current.user = @user
      sleep 0.1
      assert_equal @user, Current.user
    end

    thread2 = Thread.new do
      Current.user = @user2
      sleep 0.1
      assert_equal @user2, Current.user
    end

    thread1.join
    thread2.join
  end
end
