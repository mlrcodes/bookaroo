require 'test_helper'

class BookTest < ActiveSupport::TestCase
  def setup
    Mongoid.purge!

    @author = Author.create!(name: "Gabriel", surname: "García Márquez", country: "Colombia")

    @book = Book.new(
      title: "One Hundred Years of Solitude",
      language: "Spanish",
      status: "pending",
      score: 9.5,
      author: @author
    )
  end

  test "should be valid with valid attributes" do
    assert @book.valid?
  end

  test "should be invalid without a title" do
    @book.title = nil
    assert_not @book.valid?
    assert_includes @book.errors[:title], "can't be blank"
  end

  test "should be invalid without a language" do
    @book.language = nil
    assert_not @book.valid?
    assert_includes @book.errors[:language], "can't be blank"
  end

  # Status validation
  test "should be invalid with an invalid status" do
    @book.status = "unknown"
    assert_not @book.valid?
    assert_includes @book.errors[:status], "is not included in the list"
  end

  test "should be valid with a valid status" do
    Book::STATUSES.each do |valid_status|
      @book.status = valid_status
      assert @book.valid?, "#{valid_status} should be a valid status"
    end
  end

  test "should be invalid if score is less than 1" do
    @book.score = 0
    assert_not @book.valid?
    assert_includes @book.errors[:score], "must be between 1 and 10 in 0.5 increments"
  end

  test "should be invalid if score is greater than 10" do
    @book.score = 11
    assert_not @book.valid?
    assert_includes @book.errors[:score], "must be between 1 and 10 in 0.5 increments"
  end

  test "should be valid if score is a multiple of 0.5" do
    valid_scores = [1.0, 1.5, 5.0, 9.5, 10.0]
    valid_scores.each do |valid_score|
      @book.score = valid_score
      assert @book.valid?, "Score #{valid_score} should be valid"
    end
  end

  test "should be invalid if score is not a multiple of 0.5" do
    @book.score = 7.3
    assert_not @book.valid?
    assert_includes @book.errors[:score], "must be between 1 and 10 in 0.5 increments"
  end

  test "should allow books with same title and author but different languages" do
    @book.save!
    book2 = Book.new(
      title: "One Hundred Years of Solitude",
      language: "English",
      status: "pending",
      score: 9.5,
      author: @author
    )

    assert book2.valid?
  end

  test "should not allow books with same title, author, and language" do
    @book.save!
    duplicate_book = Book.new(
      title: "One Hundred Years of Solitude",
      language: "Spanish",
      status: "pending",
      score: 9.5,
      author: @author
    )
    assert_not duplicate_book.valid?
    assert_includes duplicate_book.errors[:title], "has already been taken for this language"
  end

  test "should allow books with same titles but different authors" do
    another_author = Author.create!(name: "Jorge", surname: "Luis Borges", country: "Argentina")
    @book.save!
    book2 = Book.new(
      title: "One Hundred Years of Solitude",
      language: "Spanish",
      status: "pending",
      score: 9.5,
      author: another_author
    )
    assert book2.valid?
  end

  test "should allow books with different titles but same author" do
    @book.save!
    book2 = Book.new(
      title: "Different title",
      language: "Spanish",
      status: "pending",
      score: 9.5,
      author: @author
    )    
    assert book2.valid?
  end
end
