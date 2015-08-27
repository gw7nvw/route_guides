class MapsController < ApplicationController

def layerswitcher
  @maplayers=Maplayer.all
end

def print
  @papersize=Papersize.all
end

def legend
  load_styles()
end

def styles
  load_styles()
  respond_to do |format|
      format.js do
      end
  end

end

def load_styles
  if params[:category] then @cat=params[:category] else @cat="routetype" end
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
     @items=Importance.all.order(:importance)
   when "rivers"
     @items=River.all.order(:difficulty)
   else 
     @items=Routetype.all.order(:difficulty)
   end
end

end
