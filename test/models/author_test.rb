require "test_helper"

class AuthorTest < Minitest::Test
  def setup
    Mongoid.purge!

    @author = Author.create!(
      name: "J.R.R.",
      surname: "Tolkien",
      country: "United Kingdom"
    )

    @book1 = @author.books.create!(title: "The Hobbit", language: "English", status: "reading", score: 4.5, image: "https://example.com/hobbit.jpg", author_id: @author._id)
    @book2 = @author.books.create!(title: "The Lord of the Rings", language: "English", status: "reading", score: 5.0, image: "https://example.com/lotr.jpg", author_id: @author._id)
  end

  def test_author_has_name
    assert_respond_to @author, :name
    assert_equal "J.R.R.", @author.name
  end

  def test_author_has_surname
    assert_respond_to @author, :surname
    assert_equal "Tolkien", @author.surname
  end

  def test_author_has_country
    assert_respond_to @author, :country
    assert_equal "United Kingdom", @author.country
  end

  def test_author_has_many_books
    assert_respond_to @author, :books
    assert_equal 2, @author.books.count
    assert_includes @author.books.map(&:title), "The Hobbit"
    assert_includes @author.books.map(&:title), "The Lord of the Rings"
  end

    def test_author_is_invalid_without_name
    author = Author.new(surname: "Tolkien", country: "United Kingdom")
    refute author.valid?, "Author should be invalid without a name"
    assert_includes author.errors[:name], "can't be blank"
  end

  def test_author_is_invalid_without_surname
    author = Author.new(name: "J.R.R.", country: "United Kingdom")
    refute author.valid?, "Author should be invalid without a surname"
    assert_includes author.errors[:surname], "can't be blank"
  end

  def test_author_is_invalid_without_country
    author = Author.new(name: "J.R.R.", surname: "Tolkien")
    refute author.valid?, "Author should be invalid without a country"
    assert_includes author.errors[:country], "can't be blank"
  end

  def test_author_is_unique_by_name_and_surname  
    duplicate_author = Author.new(name: "J.R.R.", surname: "Tolkien", country: "UK")
    refute duplicate_author.valid?, "Author with same name and surname should be invalid"
    assert_includes duplicate_author.errors[:name], "has already been taken"
  end  
end
