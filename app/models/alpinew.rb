class Alpinew < ActiveRecord::Base
  has_one :linestyle, class_name: "Difficulty", foreign_key: "difficulty", primary_key: "difficulty"

end
