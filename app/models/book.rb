class Book
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title, type: String
  field :language, type: String
  field :status, type: String, default: "pending"
  field :rating, type: Float
  field :cover_url, type: String

  belongs_to :author, class_name: "Author", inverse_of: :books

  accepts_nested_attributes_for :author, allow_destroy: true
  
  STATUSES = %w[pending reading completed abandoned].freeze

  validates :title, 
    presence: true,
    uniqueness: { 
      scope: [:author, :language], 
      case_sensitive: false, message: "book already exists" 
    }

  validates :language, 
    presence: true, 
    length: { in: 2..50 },
    format: { with: /\A[A-Za-zÀ-ÖØ-öø-ÿ\s-]+\z/, message: "must be a valid language format" }

  validates :status, inclusion: { in: STATUSES }

  validates :rating, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 10,
    message: "must be between 1 and 10 in 0.5 increments"
  }, allow_nil: true

  validate :validate_multiple_of_half

  validates :author, presence: true

  private

  def validate_multiple_of_half
    if rating.present? && (rating * 2) % 1 != 0
      errors.add(:rating, "must be between 1 and 10 in 0.5 increments")
    end
  end
end