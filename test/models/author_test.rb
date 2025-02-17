require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  def setup
    Mongoid.purge!

    @author = Author.new(
      name: "Gabriel",
      surname: "García Márquez",
      country: "Colombia"
    )
  end

  test "should be valid with valid attributes" do
    assert @author.valid?
  end

  test "should be invalid without a name" do
    @author.name = ""
    assert_not @author.valid?
    assert_includes @author.errors[:name], "can't be blank"
  end

  test "should be invalid if name format is incorrect" do
    invalid_names = ["John123", "J@ne"]
    invalid_names.each do |invalid_name|
      @author.name = invalid_name
      assert_not @author.valid?, "#{invalid_name} should be invalid"
      assert_includes @author.errors[:name], "must be valid name format"
    end
  end

  test "should be invalid if name is too short" do
    @author.name = "A"
    assert_not @author.valid?, "Name should be invalid if length is less thant 2 characters"
    assert_includes @author.errors[:name], "is too short (minimum is 2 characters)"
  end

  test "should be invalid if name is too long" do
    @author.name = "ThisAuthorNameIsWayTooLongAndInvalidSoTestNoWayWillPass"
    assert_not @author.valid?, "Name should be invalid if length is more thant 50 characters"
    assert_includes @author.errors[:name], "is too long (maximum is 50 characters)"
  end

  test "should be invalid without a surname" do
    @author.surname = ""
    assert_not @author.valid?
    assert_includes @author.errors[:surname], "can't be blank"
  end

  test "should be invalid if surname format is incorrect" do
    invalid_surnames = ["Doe123", "D@ne"]
    invalid_surnames.each do |invalid_surname|
      @author.surname = invalid_surname
      assert_not @author.valid?, "#{invalid_surname} should be invalid"
      assert_includes @author.errors[:surname], "must be valid surname format"
    end
  end

  test "should be invalid if surname is too short" do
    @author.surname = "A"
    assert_not @author.valid?, "Surname should be invalid if length is less thant 2 characters"
    assert_includes @author.errors[:surname], "is too short (minimum is 2 characters)"
  end

  test "should be invalid if surname is too long" do
    @author.surname = "ThisAuthorSurNameIsWayTooLongAndInvalidSoTestNoWayWillPass"
    assert_not @author.valid?, "Surname should be invalid if length is more thant 50 characters"
    assert_includes @author.errors[:surname], "is too long (maximum is 50 characters)"
  end

  test "should be invalid without a country" do
    @author.country = nil
    assert_not @author.valid?
    assert_includes @author.errors[:country], "can't be blank"
  end

  test "should be invalid if country format is incorrect" do
    invalid_countries = ["USA123", "C@nd@"]
    invalid_countries.each do |invalid_country|
      @author.country = invalid_country
      assert_not @author.valid?, "#{invalid_country} should be invalid"
      assert_includes @author.errors[:country], "must be a valid country format"
    end
  end

  test "should be invalid if country is too short" do
    @author.country = "A"
    assert_not @author.valid?, "Country should be invalid if length is less thant 2 characters"
    assert_includes @author.errors[:country], "is too short (minimum is 2 characters)"
  end

  test "should be invalid if country is too long" do
    @author.country = "ThisAuthorCountryIsWayTooLongAndInvalidSoTestNoWayWillPass"
    assert_not @author.valid?, "Country should be invalid if length is more thant 50 characters"
    assert_includes @author.errors[:country], "is too long (maximum is 50 characters)"
  end  

  test "should be invalid with duplicate name and surname" do
    duplicate_author = @author.dup
    @author.save!
    assert_not duplicate_author.valid?
    assert_includes duplicate_author.errors[:name], "has already been taken"
  end
  
  test "should allow an author to have many books" do
    @author.save!
    book1 = @author.books.create!(title: "Book One", language: "Spanish")
    book2 = @author.books.create!(title: "Book Two", language: "Spanish")

    assert_equal 2, @author.books.count
    assert_includes @author.books, book1
    assert_includes @author.books, book2
  end  
end