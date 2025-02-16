class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :password, type: String

  validates :name, presence: true, length: {in: 2..100}, format: { with: /\A[a-zA-ZÀ-ÿ'’-]+(?: [a-zA-ZÀ-ÿ'’-]+)*\z/, message: "must be a valid name format"}
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email format" }
  validates :password, presence: true, length: { in: 8..24 }, 
    format: { with: /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,24}\z/ }
end