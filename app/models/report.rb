class Report < ActiveRecord::Base
  has_many :reportInstances
  has_many :reportLinks
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

  validates :name, presence: true
  validates :description, presence: true

  def default_values
    self.created_at ||= self.updated_at

  end

def firstcreated_at
     t=Report.find_by_sql ["select min(rd.created_at) id from report_instances rd 
                where rd.report_id = ?", self.id]
     t.first.try(:id)

end

def revision_number
     t=Report.find_by_sql ["select count(id) id from report_instances ri 
                 where ri.report_id = ? and ri.updated_at <= ?",self.id, self.updated_at]
     t.first.try(:id)
end


end
