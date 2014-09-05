class Message < ActiveRecord::Base
  belongs_to :fromUser, class_name: "User"
  belongs_to :toUser, class_name: "User"
 
  validates :fromUser, :presence => true
  validates :subject, :presence => true
  validates :message, :presence => true


end
