require "test_helper"

class BookTest < Minitest::Test
  def setup
    Mongoid.purge! 

    @author = Author.create!(
      name: "J.R.R.",
      surname: "Tolkien",
      country: "United Kingdom"
    )

    @book_count = 0 

    @book = Book.create!(
      title: unique_title,
      language: "English",
      status: "reading",
      score: 4.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )
  end

  def unique_title
    @book_count += 1
    "The Hobbit #{@book_count}"
  end  

  def test_book_has_title
    assert_respond_to @book, :title
    assert_equal "The Hobbit #{@book_count}", @book.title
  end

  def test_book_has_language
    assert_respond_to @book, :language
    assert_equal "English", @book.language
  end

  def test_book_has_status
    assert_respond_to @book, :status
    assert_equal "reading", @book.status
  end

  def test_book_has_score
    assert_respond_to @book, :score
    assert_equal 4.5, @book.score
  end

  def test_book_has_image
    assert_respond_to @book, :image
    assert_equal "https://example.com/hobbit.jpg", @book.image
  end

  def test_book_belongs_to_author
    assert_respond_to @book, :author
    assert_equal "Tolkien", @book.author.surname
  end
  
  def test_book_is_invalid_without_title
    book = Book.new(
      language: "English",
      status: "reading",
      score: 4.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )

    refute book.valid?, "Book should be invalid without a title"
    assert_includes book.errors[:title], "can't be blank"
  end

  def test_book_is_invalid_without_language
    book = Book.new(
      title: unique_title,
      status: "reading",
      score: 4.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )

    refute book.valid?, "Book should be invalid without a language"
    assert_includes book.errors[:language], "can't be blank"
  end

  def test_book_is_invalid_with_wrong_status
    book = Book.new(
      title: unique_title,
      language: "English",
      status: "wrong status", 
      score: 4.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )

    refute book.valid?, "Book should be invalid with an incorrect status"
    assert_includes book.errors[:status], "is not included in the list"
  end

  def test_book_is_valid_with_correct_status
    valid_statuses = %w[pending reading completed abandoned]

    valid_statuses.each do |status|
      book = Book.new(
        title: unique_title,
        language: "English",
        status: status,
        score: 4.5,
        image: "https://example.com/hobbit.jpg",
        author: @author
      )

      assert book.valid?, "Book should be valid with status: #{status}"
    end
  end

  def test_book_is_invalid_with_wrong_score
    book = Book.new(
      title: unique_title,
      language: "English",
      status: "reading",
      score: 10.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )

    refute book.valid?, "Book should be invalid with score 10.5"
    assert_includes book.errors[:score], "must be between 1 and 10 in 0.5 increments"
  end

  def test_book_is_invalid_with_wrong_decimal_in_range_score
    book = Book.new(
      title: unique_title,
      language: "English",
      status: "reading",
      score: 9.43, # Invalid score (must allow only 0.5 steps)
      image: "https://example.com/hobbit.jpg",
      author: @author
    )

    refute book.valid?, "Book should be invalid with score 9.43"
    assert_includes book.errors[:score], "must be between 1 and 10 in 0.5 increments"
  end  

  def test_book_is_valid_with_correct_score
    valid_scores = [1, 2.5, 5, 7.5, 10]

    valid_scores.each do |score|
      book = Book.new(
        title: unique_title,
        language: "English",
        status: "reading",
        score: score,
        image: "https://example.com/hobbit.jpg",
        author: @author
      )

      assert book.valid?, "Book should be valid with score: #{score}"
    end
  end

  def test_book_is_invalid_without_author
    book = Book.new(
      title: unique_title,
      language: "English",
      status: "reading",
      score: 4.5,
      image: "https://example.com/hobbit.jpg"
    )

    refute book.valid?, "Book should be invalid without an author"
    assert_includes book.errors[:author], "can't be blank"
  end  

  def test_book_is_unique_per_author
    title = "The Hobbit"
    Book.create!(
      title: title,
      language: "English",
      status: "reading",
      score: 4.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )
  
    duplicate_book = Book.new(
      title: title,  # Same title as the first book
      language: "English",
      status: "completed",
      score: 5.0,
      image: "https://example.com/hobbit2.jpg",
      author: @author
    )

    refute duplicate_book.valid?, "Book with same title and author should be invalid"
    assert_includes duplicate_book.errors[:title], "has already been taken"
  end
  
  def test_books_can_have_same_author_but_different_titles  
    book2 = Book.new(
      title: "The Lord of the Rings",
      language: "English",
      status: "completed",
      score: 5.0,
      image: "https://example.com/lotr.jpg",
      author: @author
    )
  
    assert book2.valid?, "Book with different title but same author should be valid"
    assert book2.save, "Book with different title but same author should be saved successfully"
  end  

  def test_books_can_have_same_title_but_different_authors
    title = "Random title #{@book_count}"
    Book.create!(
      title: title,
      language: "English",
      status: "reading",
      score: 4.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )

    new_author = Author.create!(name: "Random", surname: "Random", country: "Random")

    book2 = Book.new(
      title: title,
      language: "English",
      status: "completed",
      score: 5.0,
      image: "https://example.com/lotr.jpg",
      author: new_author
    )
  
    assert book2.valid?, "Book with different title but same author should be valid"
    assert book2.save, "Book with different title but same author should be saved successfully"
  end  

  def test_create_book_with_existing_author
    title = unique_title
    book = Book.create_from_existing_author(
      title: title,
      language: "English",
      status: "reading",
      score: 4.5,
      image: "https://example.com/hobbit.jpg",
      author: @author
    )

    assert book.persisted?, "Book should be saved in the database"
    assert_equal title, book.title
    assert_equal @author.id, book.author.id
  end

  def test_create_book_with_new_author
    book = Book.create_with_author(
      title: "1984",
      language: "English",
      status: "completed",
      score: 5.0,
      image: "https://example.com/1984.jpg",
      author_name: "George",
      author_surname: "Orwell",
      author_country: "United Kingdom"
    )

    assert book.persisted?, "Book should be saved in the database"
    assert book.author.persisted?, "Author should be saved in the database"
    assert_equal "1984", book.title
    assert_equal "George", book.author.name
    assert_equal "Orwell", book.author.surname
    assert_equal "United Kingdom", book.author.country
  end  
end
