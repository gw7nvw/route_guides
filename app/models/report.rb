class Report < ActiveRecord::Base
  has_many :reportInstances
  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true

  validates :name, presence: true
  validates :description, presence: true

  before_save :default_values
  after_save :create_new_instance

def self.find_latest_by_user(count)
  reports=[]
  contributors=Report.find_by_sql [ 'select "createdBy_id" from reports group by "createdBy_id" order by max(updated_at) desc limit ?', count ]

  contributors.each do |c|
    r=Report.find_by_sql [ 'select * from reports where "createdBy_id" = ? order by updated_at desc limit 1', c.createdBy_id.to_s]
    if r and r.count>0 then reports=reports+r end
  end
  reports
end


def default_values
    self.created_at ||= self.updated_at
end

def create_new_instance
   reprt_instance=ReportInstance.new(self.attributes)
   reprt_instance.report_id=self.id
   reprt_instance.id=nil
   reprt_instance.createdBy_id = self.updatedBy_id #current_user.id

   reprt_instance.save
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

def links
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='report' and l."baseItem_id"=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='report' and l.item_id=?)],self.id, self.id]
end 
def linked(type)
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='report' and l."baseItem_id"=? and item_type=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='report' and l.item_id=? and "baseItem_type"=?)],self.id, type, self.id, type]
end

end
