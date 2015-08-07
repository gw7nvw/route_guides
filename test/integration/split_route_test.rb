require 'test_helper'

class SplitRouteTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end


#split route with selected place
test "split route with selected place" do
    #create route
  
    #create place at half-way point

    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61859193 -41.07151361 300,175.61823472 -41.06251490 300)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)


    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450000, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

    get '/routes/'+tr.id.to_s
    assert :success
    assert_template 'routes/show'
    assert_select 'a[href=?]', '/routes/xrc'+tr.id.to_s+"xps"

    get '/routes/xrc'+tr.id.to_s+"xps"
    assert :success
    assert_template 'routes/show_many'

    # route is shown 
    assert_select 'div#route_title1', 'testplace to testplacei2 via splittrack'
    assert_select 'div#actiontitle2', 'Select place at which to split this route:'

    #split at selected place
    rtcnt=Route.count

    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    assert :success
    assert_template 'routes/show_many'
    #new route created
    assert_equal Route.count, rtcnt+1
    tr2=Route.last

    assert_select 'div.alert', 'Success: route split. Now please edit the details of the first half of the split route'
    #correct url sequence (modify original, view new)
    assert_select 'input#urlfield[value=?]', 'xrm'+tr.id.to_s+'xrv'+tr2.id.to_s

    ############################################
    #first route is shown in edit mdoe
    #values correct
    assert_select 'input#route_startplace_name[value=?]', 'testplace'
    assert_select 'input#route_endplace_name[value=?]', 'splitplace'
    assert_select 'input#route_distance[value=?]', 501.7617389187489 #TODO expected 500

    ############################################
    #second route is shown in view mdoe
    assert_select 'div#route_title1', 'splitplace to testplacei2 via splittrack'
    assert_select 'span#route_dist1', 'Distance: 500.9 km' #TODO expected 500m
    assert_select 'div#fw_t1', "From splitplace to testplacei2"

    #all other values equal

end
#split route with added place

#no trips
#forward trip has new route segments .... pt1, pt2, ...
#reverse trip has new route segments .... -pt2, -pt1, ...

#no links ok
#linked items inherit both segments

#errors:
##Distance > 200m
##Split returned 1 segment
##Start segment lenght=0
##End segment length=0
##Save of new route failed (validation errors) (duplicate name a good one)
##Save of old route fails (dupicate name a good one)
##Copy link fails (how???)
##Create tripdetail (forwards) fails
##Create tripdetail (backwards) fails
##Update existing tripdetail fails


end
