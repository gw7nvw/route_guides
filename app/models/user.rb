class User < ActiveRecord::Base
  attr_accessor :remeber_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  has_many :places, class_name: "Place", foreign_key: "createdBy_id"
  has_many :reports, class_name: "Report", foreign_key: "createdBy_id"
  has_many :trips, class_name: "Trip", foreign_key: "createdBy_id"
  has_many :routeInstances, class_name: "Route", foreign_key: "createdBy_id"
  has_many :routes, class_name: "Route", foreign_key: "createdBy_id"
  has_many :placeInstances, class_name: "Place", foreign_key: "createdBy_id"
  belongs_to :role
  validates :role, presence: true
  validates :firstName, presence: true
  validates :lastName, presence: true

  before_save { self.email = email.downcase }
  before_save { self.name = name.downcase }
  before_create :create_remember_token

  VALID_NAME_REGEX = /\A[a-zA-Z\d\s]*\z/i
  validates :name,  presence: true, length: { maximum: 50 },
	        uniqueness: { case_sensitive: false }, format: { with: VALID_NAME_REGEX }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
		uniqueness: { case_sensitive: false }
  has_secure_password


  belongs_to :currenttrip, class_name: "Trip"

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def been_places
    bts=Beenthere.find_by_sql [ "select * from beentheres where user_id="+self.id.to_s+" and place_id>0" ]
    pls=[]
    bts.each do |bt|
      if bt.place then 
        pls+=[bt.place]
      end
    end
    pls
  end

  def been_routes
    bts=Beenthere.find_by_sql [ "select * from beentheres where user_id="+self.id.to_s+" and route_id>0" ]
    rts=[]
    bts.each do |bt|
    if bt.route then
      rts+=[bt.route]
    end
    end
    rts
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def touch
    if self then
      self.lastVisited=Time.new()
      self.save
    end
  end

  def authenticated?(attribute, token)
     digest = send("#{attribute}_digest")
    return false if digest.nil?
    Digest::SHA1.hexdigest(token.to_s)==digest
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end


  private

    def create_remember_token
      self.remember_token = User.digest(User.new_token)
    end
  
    def downcase_email
      self.email = email.downcase
    end

end
