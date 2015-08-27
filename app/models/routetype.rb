class Routetype < ActiveRecord::Base
  has_many :routes
  validates :name,  presence: true
  validates :difficulty,  presence: true
  has_one :linestyle, class_name: "Difficulty", foreign_key: "difficulty", primary_key: "difficulty"
end
