class BeenthereController < ApplicationController
before_action :touch_user

def delete
  user_id=params[:user_id]
  place_id=params[:place_id]
  route_id=params[:route_id]

  if user_id and signed_in? and (user_id==@current_user.id.to_s or @current_user.role.name=='root') then
    whereclause="user_id = "+user_id.to_s
    if place_id then whereclause=whereclause+" and place_id="+place_id.to_s end
    if route_id then whereclause=whereclause+" and route_id="+route_id.to_s end
    bts=Beenthere.find_by_sql [ " select * from beentheres where "+whereclause ]
    count=0
    bts.each do |bt|
      bt.destroy
      count=count+1
    end
    flash[:success]="Removed "+count.to_s+" entries"
    @user=User.find(user_id)  
    @places=@user.been_places.sort_by{|p| p.name}
    @places=@places.paginate(:per_page => 40, :places_page => params[:places_page])

    @routes=@user.been_routes.sort_by{|r| r.name}
    @routes=@routes.paginate(:per_page => 40, :routes_page => params[:routes_page])
    render '/users/beenthere'
  else
    flash[:error]="You are not permitted to remove this entry"
    redirect_to '/'
  end

end

def new
    @items=params[:url].split('x')[1..-1]
    placecount=0 
    routecount=0
    current_user()
    if signed_in? then 
      @items.each do |item|
        itemno=item[2..-1].to_i
        if item[0]=='p' then
          @beenthere = Beenthere.new
          @beenthere.place_id = itemno
          @beenthere.user_id=@current_user.id
          dup=Beenthere.find_by_sql [ "select id from beentheres where user_id="+@beenthere.user_id.to_s+" and place_id="+@beenthere.place_id.to_s ]
          if dup.count==0 then placecount=placecount+1 end
        end
        if item[0]=='r' or item[0]=='q' then
          @beenthere = Beenthere.new
          @beenthere.route_id = itemno.abs()
          @beenthere.user_id=@current_user.id
          dup=Beenthere.find_by_sql [ "select id from beentheres where user_id="+@beenthere.user_id.to_s+" and route_id="+@beenthere.route_id.to_s ]
          if dup.count==0 then routecount=routecount+1 end
        end
        if dup.count==0 then @beenthere.save end
      end
      flash[:success]="You bagged "+
            (if placecount>0 then placecount.to_s+" places " else "" end)+
            (if placecount>0 and routecount>0 then "and " else "" end)+
            (if routecount>0 then routecount.to_s+" route segments" else "" end)+
            (if placecount==0 and routecount==0 then "nothing new!" else "" end)
    else
      flash[:error]="You must register to start bagging routes and places"
    end
 end

end
