class Link < ActiveRecord::Base

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

   if self.item_type == "report"
     child=Report.find_by_id(self.item_id)
   end

   if self.item_type == "photo"
     child=Photo.find_by_id(self.item_id)
   end
   child

end

def parent
   if self.baseItem_type == "place"
     parent=Place.find_by_id(self.baseItem_id)
   end

   if self.baseItem_type == "route"
     parent=Route.find_by_id(self.baseItem_id)
   end


   if self.baseItem_type == "trip"
     parent=Trip.find_by_id(self.baseItem_id)
   end

   if self.baseItem_type == "report"
     parent=Report.find_by_id(self.baseItem_id)
   end

   if self.baseItem_type == "photo"
     parent=Photo.find_by_id(self.baseItem_id)
   end
   parent
end

end
