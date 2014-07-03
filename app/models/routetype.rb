class Routetype < ActiveRecord::Base
  has_many :routes
  validates :name,  presence: true
  validates :difficulty,  presence: true
end
