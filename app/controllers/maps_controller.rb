class MapsController < ApplicationController

def layerswitcher
  @maplayers=Maplayer.all
end

def print
  @papersize=Papersize.all
end

def styles
    respond_to do |format|
      format.js do
      end
    end

end

end
