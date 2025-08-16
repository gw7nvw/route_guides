class HistoryController < ApplicationController
 before_action :signed_in_user, only: [:update]


def update
     current_user()
     @itemType=params[:id].split("-")[0]
  itemId=params[:id].split("-")[1]
  if itemId then @itemId=itemId.to_i  end
  itemVersion=params[:id].split("-")[2]
  if itemVersion then @itemVersion=itemVersion.to_i end



  if params[:delete]=="Delete"
    count=0
    if @itemType=="place"
       # create new instance
       item=PlaceInstance.find_by_id(itemVersion)
       count=PlaceInstance.where(:place_id => item.place_id).count
    end

    if @itemType=="report"
       # create new instance
       item=ReportInstance.find_by_id(itemVersion)
       count=ReportInstance.where(:report => item.report_id).count
    end

    if @itemType == "route"
       item=RouteInstance.find_by_id(itemVersion)
       count=RouteInstance.where(:route_id => item.route_id).count
    end
    if count>1 and (item.updatedBy_id == @current_user.id or @current_user.role.name=="root") then
      if (item.destroy) then
        flash[:success]="Success: Version deleted" 
      else
        flash[:error]="Error: Delete failed"
      end 
    end
  end

  if params[:current]=="Merge"
    if @itemType=="route"
      #merge this instance into provided instance
      r=Route.find(itemId)
      other_r=Route.find_by_id(params[:merge_id].to_i)
      if r and other_r then
        r.updatedBy_id=@current_user.id
        r.updated_at=Time.new()
        r.merged_into_id=params[:merge_id].to_i
        r.published=false
        r.save
  
        other_r.updatedBy_id=@current_user.id
        other_r.updated_at=Time.new()
        other_r.merged_from_id=itemId
        other_r.save
      end
    end
  end

  if params[:current]=="Make current" 
    if @itemType=="place"
       # create new instance
       pi=PlaceInstance.find_by_id(itemVersion)
       pi.updatedBy_id=@current_user.id
       pi.updated_at=Time.new()

       #@copy to place 
       place=Place.find_by_id(itemId)
       place.attributes=pi.attributes.except('id', 'place_id')
       place.save

    end

    if @itemType=="report"
       # create new instance
       pi=ReportInstance.find_by_id(itemVersion)
       pi.updatedBy_id=@current_user.id
       pi.updated_at=Time.new()

       #@copy to place 
       report=Report.find_by_id(itemId)
       report.attributes=pi.attributes.except('id', 'report_id')
       report.save

    end

   if @itemType == "route"
       ri=RouteInstance.find_by_id(itemVersion)
       ri.updatedBy_id=@current_user.id
       ri.updated_at=Time.new()

       route=Route.find_by_id(itemId)
       route.attributes=ri.attributes.except('id', 'route_id', 'published')
       route.save
 
  
    end
  end
  @id=@itemType+"-"+@itemId.to_s
  params[:id]=@id
  @itemVersion=nil
  show()
end

def show
  prepare_route_vars()
  @history=true
  @showForward=1
   logger.debug @id
  if !@id then @id=params[:id] end
  @itemType=@id.split("-")[0]
  itemId=@id.split("-")[1]
  if itemId then @itemId=itemId.to_i  end
  itemVersion=@id.split("-")[2]
  if itemVersion then @itemVersion=itemVersion.to_i end
 
  
  if @itemType=="report"
     if @itemId and @itemId>0 then 
          @item=Report.find_by_id(@itemId)  
          @item_instances=ReportInstance.where("report_id = ?",@itemId).order(:updated_at)
     end
     if @itemVersion and @itemVersion>0 then @report=ReportInstance.find_by_id(@itemVersion) end
     @item_instance = @report
  end

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
