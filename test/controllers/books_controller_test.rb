require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
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

  test "should get index" do
    @book.save!
    get books_url
    assert_response :success
  end

  test "should get new" do
    @book.save!
    get new_book_url
    assert_response :success
  end

  test "should create book" do
    assert_difference("Book.count") do
      post books_url, params: { 
        book: { 
          image: @book.image, 
          language: @book.language, 
          title: @book.title,
          author_attributes: { 
            name: @author.name,
            surname: @author.surname,
            country: @author.country
          } 
        } 
      }
    end
  end

  test "should not create book without author attributes" do    
    assert_no_difference("Book.count") do
      post books_url, params: { 
        book: { 
          image: @book.image, 
          language: @book.language, 
          title: @book.title
        } 
      }    
    end

    assert_response :unprocessable_entity  
    assert_select "div.alert", "All fields (title, language, and author details) are required."
  end

  test "should not create book without title" do    
    assert_no_difference("Book.count") do
      post books_url, params: { 
        book: { 
          image: @book.image, 
          language: @book.language, 
          author: @author
        } 
      }    
    end

    assert_response :unprocessable_entity  
    assert_select "div.alert", "All fields (title, language, and author details) are required."
  end

  test "should not create book without language" do    
    assert_no_difference("Book.count") do
      post books_url, params: { 
        book: { 
          image: @book.image, 
          title: @book.title,
          author: @book.author
        } 
      }    
    end

    assert_response :unprocessable_entity  
    assert_select "div.alert", "All fields (title, language, and author details) are required."
  end

  test "should show book" do
    @book.save!
    get book_url(@book)
    assert_response :success
  end

  test "should get edit" do
    @book.save!
    get edit_book_url(@book)
    assert_response :success
  end

  test "should update book" do
    @book.save!
    patch book_url(@book), params: { book: { image: @book.image, language: @book.language, title: @book.title } }
    assert_redirected_to book_url(@book)
  end

  test "should destroy book" do
    @book.save!
    assert_difference("Book.count", -1) do
      delete book_url(@book)
    end

    assert_redirected_to books_url
  end
end
