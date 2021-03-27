class PhotosController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]
 before_action :touch_user

def new
   @edit=true
   @photo=Photo.new
    # default preojection is NZTM2000
    @photo.projection_id=2193

end

def index
    @searchtext=params[:searchtext]
    whereclause="true"
    if params[:searchtext] then
       whereclause=whereclause+" and lower(name) like '%%"+@searchtext.downcase+"%%'"
    end

    @photos=Photo.where(whereclause)
    if params[:order]=='latest' then
      @photos=@photos.order('updated_at desc')
      @order='latest'
    else
      @photos=@photos.order('name')
    end
    @count=@photos.count
    @photos=@photos.paginate(:per_page => 20, :page => params[:page])
end

def create
    @photo = Photo.new(photo_params)
    convert_location_params()

    #revision control
    @photo.createdBy_id = @current_user.id #current_user.id

    dupPhoto=Photo.find_by_sql ['select * from photos where "name"=? and location=?',@photo.name, @photo.location]
     logger.debug dupPhoto.count
    if (session[:save] and (Time.now - session[:save])<60) or dupPhoto.count>0  then
       #save already in procgress
       logger.debug "errorwith 409"
       render nothing: true, status: 409
    else
      session[:save]=Time.now
      success=@photo.save
      session[:save]=nil
      if success

        flash[:success] = "New photo added, id:"+@photo.id.to_s
        @id=@photo.id

        show()
        render 'show'
      else
        flash[:error] = "Error creating photo"
        @edit=true
        render 'new'
      end
    end
end

def edit
   @edit=true

    if !@id then @id=params[:id] end

    if( !(@photo = Photo.find_by_id(@id))) then
    #place does not exist - return to home
       redirect_to root_url
    end

end

def update
  if (params[:save]) then

    if( !@photo= Photo.find_by_id(params[:id]))
       #tried to update a nonexistant photo
       @edit=true
       render 'edit'
    end

    original_file=@photo.image
    @photo.attributes = photo_params
    if(!@photo.image) then @photo.image=original_file end
    convert_location_params()

    success=@photo.save
    if success then

        flash[:success] = "Photo updated, id:"+@photo.id.to_s
        @id=@photo.id

        show()
        render 'show'
    else
        flash[:error] = "Error saving photo"
        @edit=true
        render 'edit'
    end
  end
  
   if (params[:delete])

     photo=Photo.find_by_id(params[:id])

     #will need to delete any links, once they've been implemented
     links=photo.links
     links.each do |l|
        l.destroy
     end

     if photo.destroy
       flash[:success] = "Photo deleted, id:"+params[:id]
       redirect_to '/'
     else
       edit()
       render 'edit'
     end
  end


end

def show
    if !@id then @id=params[:id] end
    if params[:editlinks] then @editlinks=true end

    @edit=false
    if( !(@photo = Photo.find_by_id(@id))) then
    #place does not exist - return to home
       redirect_to root_url
    end

end

  private
  def photo_params
    params.require(:photo).permit(:name, :author, :taken_at, :description, :location, :subject_location, :image, :projection_id, :x, :y)
  end

  def convert_location_params
    #recalculate location from passed x,y params
    if(photo_params[:x] and photo_params[:x].length>0) then @photo.x=photo_params[:x].to_f end
    if(photo_params[:y] and photo_params[:y].length>0) then @photo.y=photo_params[:y].to_f end

    if(@photo.x and @photo.y)
       # convert to WGS84 (EPSG4326) fro database 
       fromproj4s= @photo.projection.proj4
       toproj4s=  Projection.find_by_id(4326).proj4

       fromproj=RGeo::CoordSys::Proj4.new(fromproj4s)
       toproj=RGeo::CoordSys::Proj4.new(toproj4s)

       xyarr=RGeo::CoordSys::Proj4::transform_coords(fromproj,toproj,@photo.x,@photo.y)

       params[:location]=xyarr[0].to_s+" "+xyarr[1].to_s
       @photo.location='POINT('+params[:location]+')'
    end
  end

end
