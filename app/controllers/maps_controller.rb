class MapsController < ApplicationController

def layerswitcher
  @maplayers=Maplayer.all
end

def print
  @papersize=Papersize.all
end

def legend
  load_styles()
  @routeclasses=Routeclass.all.order(:name)
  @projections=Projection.all.order(:name)
  if params[:projection] then @projection=params[:projection] else @projection="2193" end

end

def styles
  load_styles()
  respond_to do |format|
      format.js do
      end
  end

end

def load_styles
 
 if params[:category] then @cat=params[:category] else @cat="routetype_id" end
  if(@cat[@cat.length-3..@cat.length]=='_id') then @cat=@cat[0..@cat.length-4] end
  puts "cat: "+@cat
  case @cat 

   when "alpinesummer"
     @items=Alpine.all.order(:difficulty)
   when "alpinewinter"
     @items=Alpinew.all.order(:difficulty)
   when "terrain"
     @items=Terrain.all.order(:difficulty)
   when "gradient"
     @items=Gradient.all.order(:difficulty)
   when "importance"
     @items=RouteImportance.all.order(:importance)
   when "river"
     @items=River.all.order(:difficulty)
   else 
     @items=Routetype.all.order(:difficulty)
   end
end

end
