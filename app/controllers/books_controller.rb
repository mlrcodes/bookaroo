class BooksController < ApplicationController
  before_action :set_user
  before_action :set_book, only: %i[ show ]

  # GET /books/1 or /books/1.json
  def show
  end

  # POST /user/books or /user/books.json
  def create
    author_params = book_params[:author_attributes] || {}

    @author = Author.find_or_create_by(
      name: author_params[:name],
      surname: author_params[:surname],
      country: author_params[:country]
    )

    @book = Book.new(
      title: book_params[:title],
      language: book_params[:language],
      image: book_params[:image],
      author: @author,
    )         

    @user.books << @book

    if @user.save
      redirect_to @user, notice: "Book was successfully created."   
    else
      render "/users/show", status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_user
      @user = User.find(params[:user_id])
    end

    # Finds the book only within the scope of the user
    def set_book
      @book = @user.books.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:title, :language, :image, author_attributes: [:name, :surname, :country])
    end
end
