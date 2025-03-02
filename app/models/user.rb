class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :name, type: String
  field :email, type: String
  field :password_digest, type: String
  field :reset_password_token, type: String
  field :reset_password_sent_at, type: Time

  has_secure_password

  has_and_belongs_to_many :books, class_name: "Book", inverse_of: nil

  validates :name, 
    presence: true, 
    length: {in: 2..100}, 
    format: { 
      with: /\A[a-zA-ZÀ-ÿ'’-]+(?: [a-zA-ZÀ-ÿ'’-]+)*\z/, 
      message: "must be a valid name format"
    }
  
  validates :email, 
    presence: true, 
    uniqueness: true, 
    format: { 
      with: /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/, 
      message: "must be a valid email format" 
    }
  
  validates :password, 
    presence: true, 
    length: { in: 8..24 }, 
    format: { 
      with: /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,24}\z/, 
      message: "must be a valid password format" 
    },
    if: -> { new_record? || password.present? || (reset_password_token.present? && !password_reset_token_expired?) }

  def generate_password_reset_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!(validate: false)
  end

  # Checks if token has expired (15 minutes limit)
  def password_reset_token_expired?
    reset_password_sent_at.nil? || reset_password_sent_at < 15.minutes.ago
  end

  # Clear token after successful reset  
  def clear_password_reset_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end 
  
  def self.authenticate(email:, password:) 
    user = User.where(email: email).first
    user&.authenticate(password)
  end
end
