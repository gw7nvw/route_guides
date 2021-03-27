class LinksController < ApplicationController
 before_action :signed_in_user, only: [:create, :destroy]
 before_action :touch_user

 def create
   @render_to='editlinks'
   
   @parent_type=params[:parent_type]
   case params[:parent_type]
   when 'report'
     @parent=Report.find_by_id(params[:parent_id])
   when 'route'
     @parent=Route.find_by_id(params[:parent_id].to_i.abs)
   when 'place'
     @parent=Place.find_by_id(params[:parent_id])
   when 'photo'
     @parent=Photo.find_by_id(params[:parent_id])
   when 'trip'
     @parent=Trip.find_by_id(params[:parent_id])
   end

   if params[:commit] and params[:commit][0..5]=='delete' then
     deleteId=params[:commit][6..-1].to_i

    link=Link.find_by_id(params[:commit][6..-1].to_i)
     if (link)
        if(link.destroy)
           flash[:success] = "Removed link from report:"+params[:commit][6..-1]
        end
     else
        flash[:error] = "Cannot find link to delete:"+params[:commit][6..-1]
     end

   end

   if params[:commit] and params[:commit]=='addLink' then
        rl=Link.new()
        rl.baseItem_id=params[:parent_id].to_i.abs
        rl.baseItem_type=params[:parent_type]
        rl.item_id=params[:itemId].to_i.abs
        rl.item_type=params[:itemType]
        if params[:itemType]=='Places' then rl.item_type='place' end
        if params[:itemType]=='Routes' then rl.item_type='route' end
        if rl.item_type=="URL" or rl.item_type=="page"  then
          rl.item_url=params[:itemName]
          if rl.item_url[0..3]!='http' then rl.item_url="http://"+rl.item_url end
        end
      if((rl.item_id and rl.item_id.to_i>0) or rl.item_url) and  (rl.baseItem_id and  rl.baseItem_id>0)
        rl.save
        regen=false
        if @parent_type=="route" then
          @parent.queue_regenerate_route_index 
          regen=true
        end 
        if regen==false and rl.item_type=="route" then
           child=Route.find_by_id(rl.item_id)
           if child then 
             regen=true
             child.queue_regenerate_route_index 
           end
        end
        if regen==false and @parent_type=="place" then
          rs=@parent.adjoiningRoutes
          rs.each do |r|
             r.queue_regenerate_route_index
             regen=true
          end
        end
        if regen==false and rl.item_type=="place" then
          child=Place.find_by_id(rl.item_id)
          rs=child.adjoiningRoutes
          rs.each do |r|
             r.queue_regenerate_route_index
             regen=true
          end
        end
      end
   
   end


   render 'edit' 
 end

end
