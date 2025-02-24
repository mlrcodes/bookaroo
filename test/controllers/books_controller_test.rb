require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    Mongoid::Clients.default.database.drop
    @user = User.new(name: "UserName", email: "email@example.com", password: "MySecurePassword#123")
    @author = Author.create!(name: "Gabriel", surname: "García Márquez", country: "Colombia")
    @book = Book.create(
      title: "One Hundred Years of Solitude",
      language: "Spanish",
      author: @author
    )  
    @user.books <<  @book
    @user.save!
  end

  test "should create book" do
    assert_difference("Book.count") do
      post user_books_url @user, params: { 
        book: { 
          language: @book.language, 
          title: "Random Title",
          author_attributes: { 
            name: @author.name,
            surname: @author.surname,
            country: @author.country
          } 
        } 
      }
    end

    assert_redirected_to user_path @user    
  end

  test "should not create book without author attributes" do    
    assert_no_difference("Book.count") do
      post user_books_url @user, params: { 
        book: { 
          image: @book.image, 
          language: @book.language, 
          title: @book.title
        } 
      }    
    end

    assert_response :unprocessable_entity  
  end

  test "should not create book without title" do    
    assert_no_difference("Book.count") do
      post user_books_url @user, params: { 
        book: { 
          image: @book.image, 
          language: @book.language, 
          author: @book.author
        } 
      }    
    end

    assert_response :unprocessable_entity  
  end

  test "should not create book without language" do    
    assert_no_difference("Book.count") do
      post user_books_url @user, params: { 
        book: { 
          image: @book.image, 
          title: @book.title,
          author: @book.author
        } 
      }     
    end
    assert_response :unprocessable_entity  
  end

  test "should show book" do
    get user_book_url(@user, @book)
    assert_response :success
  end
end
