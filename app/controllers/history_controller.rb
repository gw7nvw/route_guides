class HistoryController < ApplicationController

def update
     current_user()
     @itemType=params[:id].split("-")[0]
  itemId=params[:id].split("-")[1]
  if itemId then @itemId=itemId.to_i  end
  itemVersion=params[:id].split("-")[2]
  if itemVersion then @itemVersion=itemVersion.to_i end


  logger.debug @itemType+"|"+params[:current]

  if params[:current]=="Make current" 
    if @itemType=="place"
       # create new instance
       pi=PlaceInstance.find_by_id(itemVersion).dup
       pi.createdBy_id=@current_user.id
       pi.save

       #@copy to place 
       place=Place.find_by_id(itemId)
       place.name=pi.name
       place.description=pi.description
       place.x=pi.x
       place.y=pi.y
       place.projn=pi.projn
       place.altitude=pi.altitude
       place.createdBy_id=pi.createdBy_id
       place.save
    end

    if @itemType == "route"
  
    end
  end
  @id=@itemType+"-"+@itemId.to_s
  @itemVersion=nil
  show()
end

def show
  prepare_route_vars()
  @history=true
   logger.debug @id
  if !@id then @id=params[:id] end
  @itemType=@id.split("-")[0]
  itemId=@id.split("-")[1]
  if itemId then @itemId=itemId.to_i  end
  itemVersion=@id.split("-")[2]
  if itemVersion then @itemVersion=itemVersion.to_i end
 
  
  if @itemType=="place"
     if @itemId and @itemId>0 then 
          @item=Place.find_by_id(@itemId)  
          @item_instances=PlaceInstance.where("place_id = ?",@itemId).order(:updated_at)
     end
     if @itemVersion and @itemVersion>0 then @place=PlaceInstance.find_by_id(@itemVersion) end
     @item_instance = @place
  end

  if @itemType=="route"
     if @itemId and @itemId>0 then 
          @item=Route.find_by_id(@itemId)  
          @item_instances=RouteInstance.where("route_id = ?",@itemId).order(:updated_at)
     end
     if @itemVersion and @itemVersion>0 then @route=RouteInstance.find_by_id(@itemVersion) end
     @item_instance = @route
  end

  if !@itemVersion or @itemVersion<1 then
     render 'index'
  else
     render 'show'
  end
end
end
