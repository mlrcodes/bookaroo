class Author
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :surname, type: String
  field :country, type: String

  has_many :books, class_name: "Book", inverse_of: :author, dependent: :destroy  

  validates :name, 
    presence: true,
    length: { in: 2..50 },
    format: { with: /\A[a-zA-ZÀ-ÿ'’-]+(?: [a-zA-ZÀ-ÿ'’-]+)*\z/, message: "must be valid name format" }

  validates :surname, 
    presence: true,
    length: { in: 2..50 },
    format: { with: /\A[a-zA-ZÀ-ÿ'’-]+(?: [a-zA-ZÀ-ÿ'’-]+)*\z/, message: "must be valid surname format" }
    
  validates :country,
      presence: true,
      length: { in: 2..50 },
      format: { with: /\A[A-Za-zÀ-ÖØ-öø-ÿ\s'-]+\z/, message: "must be a valid country format" }

  validates :name, uniqueness: { scope: :surname, case_sensitive: false, message: "has already been taken" }

  # Ensure uniqueness in MongoDB
  index({ name: 1, surname: 1 }, unique: true)
end
