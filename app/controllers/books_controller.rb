class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    @books = Book.all
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
    @author = @book.build_author
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    author_params = book_params[:author_attributes] || {}

    if missing_required_params?
      @book = Book.new(book_params)      
      p @book
      flash[:error] = "All fields (title, language, and author details) are required."
      render :new, status: :unprocessable_entity 
      return
    end

    @author = Author.find_or_create_by(
      name: author_params[:name],
      surname: author_params[:surname],
      country: author_params[:country]
    )

    @book = Book.find_or_create_by(
      title: book_params[:title],
      language: book_params[:language],
      image: book_params[:image],
      author: @author,
    )

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "Book was successfully updated." }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy!

    respond_to do |format|
      format.html { redirect_to books_path, status: :see_other, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:title, :language, :image, author_attributes: [:name, :surname, :country])
    end

    def missing_required_params?
      required_fields = [:title, :language, :author_attributes]
      author_required_fields = [:name, :surname, :country]

      # Check if book fields are missing
      missing_fields = required_fields.any? { |field| book_params[field].blank? }

      # Check if author fields are missing
      author_params = book_params[:author_attributes] || {}
      missing_author_fields = author_required_fields.any? { |field| author_params[field].blank? }

      missing_fields || missing_author_fields
    end

end
