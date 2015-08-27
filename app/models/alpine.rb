class Alpine < ActiveRecord::Base
  has_many :routes
  validates :description,  presence: true
  validates :difficulty,  presence: true
  has_one :linestyle, class_name: "Difficulty", foreign_key: "difficulty", primary_key: "difficulty"

end
