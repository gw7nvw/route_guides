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
     @parent=Route.find_by_id(params[:parent_id])
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
        rl.baseItem_id=params[:parent_id]
        rl.baseItem_type=params[:parent_type]
        rl.item_id=params[:itemId]
        rl.item_type=params[:itemType]
        if rl.item_type=="URL" or rl.item_type=="page"  then
          rl.item_url=params[:itemName]
        end
      if((rl.item_id and rl.item_id.to_i>0) or rl.item_url) and  (rl.baseItem_id and  rl.baseItem_id>0)
        rl.save
      end

   end

   render 'edit' 
 end

end
