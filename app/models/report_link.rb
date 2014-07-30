class ReportLink < ActiveRecord::Base

def child
   if self.item_type == "place"
     child=Place.find_by_id(self.item_id)

   end


   if self.item_type == "route"
     child=Route.find_by_id(self.item_id)
   end


   if self.item_type == "trip"
     child=Trip.find_by_id(self.item_id)
   end

   child

end

def report
   report=Report.find_by_id(self.report_id)
end

end
