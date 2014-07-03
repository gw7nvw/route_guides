class Alpine < ActiveRecord::Base
  has_many :routes
  validates :description,  presence: true
  validates :difficulty,  presence: true

end
