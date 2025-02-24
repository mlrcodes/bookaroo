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

  test "should be invalid if language format is incorrect" do
    invalid_languages = ["Eng1ish", "123", "A#Ea"]
    invalid_languages.each do |invalid_language|
      @book.language = invalid_language
      assert_not @book.valid?, "#{invalid_language} should be invalid"
      assert_includes @book.errors[:language], "must be a valid language format"
    end
  end

  test "should be invalid if language format is too short" do
    @book.language = "A"
    assert_not @book.valid?, "Title should be an invalid if length is less thant 2 characters"
    assert_includes @book.errors[:language], "is too short (minimum is 2 characters)"
  end

  test "should be invalid if language format is too long" do
    @book.language = "ThisLanguageIsWayTooLongAndInvalidSoTestNoWayWillPass"
    assert_not @book.valid?, "Title should be an invalid if length is more thant 40 characters"
    assert_includes @book.errors[:language], "is too long (maximum is 50 characters)"
  end

  test "should be valid if language format is correct" do
    valid_languages = ["English", "Español", "Français", "Deutsch", "Português"]
    valid_languages.each do |valid_language|
      @book.language = valid_language
      assert @book.valid?, "#{valid_language} should be valid"
    end
  end

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

  test "should have a default score of 5" do
    new_book = Book.create!(title: "Default Score Book", language: "English", status: "pending", author: @book.author)
    assert_equal 5, new_book.score, "Default score should be 5"
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

  test "should be invalid without an author" do
    @book.author = nil
    assert_not @book.valid?
    assert_includes @book.errors[:author], "can't be blank"
  end

  test "should allow books with same title and author but different languages" do
    @book.save!
    book2 = Book.new(
      title: @book.title,
      language: "English",
      author: @author
    )

    assert book2.valid?
  end

  test "should not allow books with same title, author, and language" do
    @book.save!
    duplicate_book = Book.new(
      title: @book.title,
      language: @book.language,
      author: @author
    )
    assert_not duplicate_book.valid?
    assert_includes duplicate_book.errors[:title], "book already exists"
  end

  test "should allow books with same titles but different authors" do
    another_author = Author.create!(name: "Jorge", surname: "Luis Borges", country: "Argentina")
    @book.save!
    book2 = Book.new(
      title: @book.title,
      language: @book.language,
      author: another_author
    )
    assert book2.valid?
  end

  test "should allow books with different titles but same author" do
    @book.save!
    book2 = Book.new(
      title: "Different title",
      language: @book.language,
      author: @book.author
    )    
    assert book2.valid?
  end
end