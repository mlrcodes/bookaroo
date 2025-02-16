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

  test "should be invalid without a surname" do
    @author.surname = ""
    assert_not @author.valid?
    assert_includes @author.errors[:surname], "can't be blank"
  end

  test "should be invalid without a country" do
    @author.country = ""
    assert_not @author.valid?
    assert_includes @author.errors[:country], "can't be blank"
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
