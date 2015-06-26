class Guest < ActiveRecord::Base
  attr_accessor :remeber_token
  belongs_to :currenttrip, class_name: "Trip"


  def Guest.new_token
    SecureRandom.urlsafe_base64
  end

  def Guest.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end


end
