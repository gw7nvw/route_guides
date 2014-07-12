class Role < ActiveRecord::Base

  validates :name,  presence: true, length: { maximum: 20 },
                uniqueness: { case_sensitive: false }
  has_many :user
end
