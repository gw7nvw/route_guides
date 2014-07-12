class User < ActiveRecord::Base
  has_many :places, class_name: "Place", foreign_key: "createdBy_id"
  has_many :routes, class_name: "Route", foreign_key: "createdBy_id"
  belongs_to :role
  validates :role, presence: true

  before_save { self.email = email.downcase }
  before_create :create_remember_token

  validates :name,  presence: true, length: { maximum: 50 },
	        uniqueness: { case_sensitive: false }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
		uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: {minimum: 5 }

  belongs_to :currenttrip, class_name: "Trip"

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end
end
