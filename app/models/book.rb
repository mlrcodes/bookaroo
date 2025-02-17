class Book
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  field :language, type: String
  field :status, type: String, default: "pending"
  field :score, type: Float, default: 5
  field :image, type: String

  belongs_to :author, class_name: "Author", inverse_of: :books
  
  STATUSES = %w[pending reading completed abandoned].freeze

  validates :title, presence: true

  validates :language, 
    presence: true, 
    length: { in: 2..50 },
    format: { with: /\A[A-Za-zÀ-ÖØ-öø-ÿ\s-]+\z/, message: "must be a valid language format" }

    validates :status, inclusion: { in: STATUSES }

  validates :score, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 10,
    message: "must be between 1 and 10 in 0.5 increments"
  }, allow_nil: true

  validate :validate_multiple_of_half

  validates :title, uniqueness: { scope: [:author, :language], case_sensitive: false, message: "has already been taken for this language" }

  # Factory method: Creates a book with an existing author
  def self.create_from_existing_author(title:, language:, status:, score:, image:, author:)
    Book.create!(title: title, language: language, status: status, score: score, image: image, author: author)
  end

  # Factory method: Creates a book and a new author in one step
  def self.create_with_author(title:, language:, status:, score:, image:, author_name:, author_surname:, author_country:)
    author = Author.find_or_create_by!(name: author_name, surname: author_surname, country: author_country)
    Book.create!(title: title, language: language, status: status, score: score, image: image, author: author)
  end

  private

  def validate_multiple_of_half
    if score.present? && (score * 2) % 1 != 0
      errors.add(:score, "must be between 1 and 10 in 0.5 increments")
    end
  end
end