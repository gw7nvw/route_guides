class Comment < ActiveRecord::Base
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true
  validates :comment, :presence => true
  validates :item_id, :presence => true
  validates :item_type, :presence => true

end
