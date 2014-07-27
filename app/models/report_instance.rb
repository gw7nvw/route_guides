class ReportInstance < ActiveRecord::Base
 belongs_to :rport
 belongs_to :createdBy, class_name: "User"


def firstcreated_at
   self.created_at
end
def revision_number
     t=ReportInstance.find_by_sql ["select count(id) id from report_instances ri 
                 where ri.report_id = ? and ri.updated_at <= ?",self.report_id, self.updated_at]
     t.first.try(:id)
end


end
