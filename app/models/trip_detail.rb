class TripDetail < ActiveRecord::Base
  belongs_to :trip
  belongs_to :route
  belongs_to :place

  validates :trip, presence: true
  validates :order, presence: true

end
