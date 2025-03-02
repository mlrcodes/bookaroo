require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    Mongoid.purge! 
    
    @password = "MySecurePassword#123"
    @user = User.new(name: "John Doe", email: "john.doe@example.com", password: @password)

    @author = Author.create!(name: "Name", surname: "Surname", country: "Country")
    @book1 = Book.create!(title: "Title 1", language: "Language", author: @author) 
    @book2 = Book.create!(title: "Title 2", language: "Language", author: @author)
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

  test "should be invalid with a blank password" do
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
    @user.password = "MYSECUREPASSWORD#123"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "must be a valid password format"
  end

  test "should be invalid without a number in password" do
    @user.password = "MySecurePassword#"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "must be a valid password format"
  end

  test "should be invalid without a special character in password" do
    @user.password = "MySecurePassword123"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "must be a valid password format"
  end

  test "should allow the same user to record different books" do
    @user.save!
    @user.books << @book1
    @user.books << @book2

    assert_includes @user.books, @book1
    assert_includes @user.books, @book2
  end

  test "should allow different users to record the same book" do
    @user.save!
    user2 = User.create!(name: @user.name, email: "example2@mail.com", password: @password)
    
    @user.books << @book1
    user2.books << @book1

    @user.save!
    user2.save!

    assert_includes @user.books, @book1
    assert_includes user2.books, @book1
  end

  test "should not allow the same user to record the same book twice" do
    @user.save!
    @user.books << @book1

    assert_no_difference "@user.books.count" do
      @user.books << @book1
      @user.save!
    end
  
    assert @user.valid?
  end  

  test "should not allow the same user to record a repeated book" do
    @user.save!
    @user.books << @book1
    @user.books.build(
      title: @book1.title,
      language: @book1.language,
      author: @book1.author
    )
  
    assert_not @user.valid?
    assert_includes @user.errors[:books], "is invalid"
  end    

  test "should generate password reset token" do
    assert_nil @user.reset_password_token
    assert_nil @user.reset_password_sent_at

    @user.generate_password_reset_token!

    assert_not_nil @user.reset_password_token
    assert_not_nil @user.reset_password_sent_at
    assert_operator @user.reset_password_sent_at, :<=, Time.current
  end  

  test "should return false if token is not expired" do
    @user.generate_password_reset_token!
    assert_not @user.password_reset_token_expired?, "Token should NOT be expired"
  end

  test "should return true if token is expired" do
    @user.generate_password_reset_token!
    @user.update!(reset_password_sent_at: 16.minutes.ago)

    assert @user.password_reset_token_expired?, "Token should be expired"
  end

  test "should clear password reset token" do
    @user.generate_password_reset_token!
    assert_not_nil @user.reset_password_token
    assert_not_nil @user.reset_password_sent_at

    @user.clear_password_reset_token!

    assert_nil @user.reset_password_token
    assert_nil @user.reset_password_sent_at
  end
end
