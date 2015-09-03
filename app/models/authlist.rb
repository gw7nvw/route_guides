class Authlist < ActiveRecord::Base
  attr_accessor :auth_token

  before_create :create_auth_digest
  validates :name, :presence => true

#  before_save :downcase_fromEmail
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :address, format: { with: VALID_EMAIL_REGEX }, :uniqueness => true

  def Message.new_token
    SecureRandom.urlsafe_base64
  end

  def Message.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  # Sends auth email.
  def send_auth_email
    UserMailer.address_auth(self).deliver
  end

  def downcase_address
      self.address = address.downcase
  end

  def create_auth_digest
    self.auth_token  = Message.new_token
    self.auth_digest = Message.digest(auth_token)
  end

  def authenticated?(attribute, token)
     digest = send("#{attribute}_digest")
    return false if digest.nil?
    Digest::SHA1.hexdigest(token.to_s)==digest
  end

  # Activates an account.
  def activate
    update_attribute(:allow,    true)
    messages=Message.find_by_sql ['select * from messages where "fromName" = ? and "fromEmail" = ?', self.name, self.address]
    messages.each do |m|
        m.approved=true
        m.save
    end
    comments=Comment.find_by_sql ['select * from comments where "fromName" = ? and "fromEmail" = ?', self.name, self.address]
    comments.each do |m|
        m.approved=true
        m.save
    end
  end

  def self.create_or_replace(authlist)
    foundError=false
    #check for existing entries
    als=Authlist.find_by_sql [ 'select * from authlists where "address"=?', authlist[:address] ]
    if als.count>0
      als.each do |al|
        #remove unauthenticated duplicates, error for valid existing entries
        if al.forbid==true or al.allow==true then foundError=true end
        if al.forbid==false and al.allow==false then al.destroy end
     end
    end
    if foundError==false then
       Authlist.create(authlist)
    else
       nil
    end 
  end
end
