class Beenthere < ActiveRecord::Base
  belongs_to :place
  belongs_to :route
  belongs_to :user 

end
