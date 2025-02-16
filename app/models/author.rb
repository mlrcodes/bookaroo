class Author
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :surname, type: String
  field :country, type: String

  has_many :books, class_name: "Book", inverse_of: :author, dependent: :destroy  

  validates :name, :surname, :country, presence: true
  validates :name, uniqueness: { scope: :surname, case_sensitive: false, message: "has already been taken" }

  # Ensure uniqueness in MongoDB
  index({ name: 1, surname: 1 }, unique: true)
end
