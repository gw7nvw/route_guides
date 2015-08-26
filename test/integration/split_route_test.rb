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
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)
    #tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300, 175.61823472 -41.07 200, 175.61823472 -41.064 100, 175.61823472 -41.06251490 000)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450500, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

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
    tr.reload

    assert_select 'div.alert', 'Success: route split. Now please edit the details of the first half of the split route'
    #correct url sequence (modify original, view new)
    assert_select 'input#urlfield[value=?]', 'xrm'+tr.id.to_s+'xrv'+tr2.id.to_s

    ############################################
    #first route is shown in edit mdoe
    #values correct
    assert_select 'input#route_startplace_name[value=?]', 'testplace'
    assert_select 'input#route_endplace_name[value=?]', 'splitplace'
    assert_select 'input#route_distance[value=?]', 500.865350899489 #TODO expected 500

    ############################################
    #second route is shown in view mdoe
    assert_select 'div#route_title1', 'splitplace to testplacei2 via splittrack part 2'
#    assert_select 'span#route_dist1', 'Distance: 0.5 km' #TODO expected 500m
    assert_select 'div#fw_t1', "From splitplace to testplacei2"

    #updated_by
    assert_equal tr.updatedBy_id, @testuser2.id
    assert_equal tr2.updatedBy_id, @testuser2.id

    #location
    assert_equal tr.location.as_text, "LINESTRING (175.61823472 -41.07151361 300.0, 175.61823472 -41.06701426 300.0)"
    assert_equal tr2.location.as_text, "LINESTRING (175.61823472 -41.06701426 200.0, 175.61823472 -41.0625149 200.0)"

    #altitude
    assert_equal tr.altloss, 0
    assert_equal tr.altgain, 0
    assert_equal tr.minalt, 300
    assert_equal tr.maxalt, 300
    assert_equal tr2.altloss, 0
    assert_equal tr2.altgain, 0
    assert_equal tr2.minalt, 200
    assert_equal tr2.maxalt, 200

    #intances
    #original route now has 2 instances
    assert_equal tr.routeInstances.count, 2
    assert_equal tr2.routeInstances.count, 1

    #all other values equal
    assert_equal tr.description, tr2.description
    assert_equal tr.routetype_id, tr2.routetype_id
    assert_equal tr.terrain_id, tr2.terrain_id
    assert_equal tr.alpinesummer_id, tr2.alpinesummer_id
    assert_equal tr.river_id, tr2.river_id
    assert_equal tr.alpinewinter_id, tr2.alpinewinter_id
    assert_equal tr.winterdescription, tr2.winterdescription
    assert_equal tr.createdBy_id, tr2.createdBy_id
#    assert_equal tr.created_at, tr2.created_at
    assert_equal tr.via[0..-2], tr2.via[0..-2]
    assert_equal tr.reverse_description, tr2.reverse_description
    assert_equal tr.time, tr2.time
    assert_equal tr.datasource, tr2.datasource
    assert_equal tr.published, tr2.published
    assert_equal tr.experienced_at, tr2.experienced_at

    ############################################
    #save pt1, part 2 placed in edit mode
    patch '/routes/'+tr.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: tp.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.61823472 -41.07151361 300.0, 175.61823472 -41.06701426 300.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "0.5", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: 'xrm'+tr.id.to_s+'xrv'+tr2.id.to_s

    assert :success
    assert_template 'routes/show_many'
    tr.reload

    assert_select 'div.alert', 'First segment updated. Now please update the details of the second part of the split route'
    #correct url sequence (modify original, view new)
    assert_select 'input#urlfield[value=?]', 'xrv'+tr.id.to_s+'xre'+tr2.id.to_s

    ############################################
    #first route is shown in view mdoe
    assert_select 'div#route_title1', 'testplace to splitplace via changedvia'
    assert_select 'div#fw_t1', "From testplace to splitplace"

    ############################################
    #second route is shown in edit mdoe
    #values correct
    assert_select 'input#route_startplace_name[value=?]', 'splitplace'
    assert_select 'input#route_endplace_name[value=?]', 'testplacei2'
    assert_select 'input#route_distance[value=?]', 500.8664640973013 #TODO expected 0.500

    ############################################
    #save pt2, part 2 placed in edit moderts 1 and 2 shown as view
    patch '/routes/'+tr2.id.to_s, route: { startplace_id: tp.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.61823472 -41.06701426 200.0, 175.61823472 -41.0625149 200.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "0.5", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: 'xrv'+tr.id.to_s+'xre'+tr2.id.to_s

    assert :success
    assert_template 'routes/show_many'
    tr.reload

    assert_select 'div.alert', 'Route updated, id:'+tr2.id.to_s
    #correct url sequence (modify original, view new)
#    assert_select 'input#urlfield[value=?]', 'xrv'+tr.id.to_s+'xrv'+tr2.id.to_s

    ############################################
    #first route is shown in view mdoe
    assert_select 'div#route_title1', 'testplace to splitplace via changedvia'
    assert_select 'div#fw_t1', "From testplace to splitplace"

    ############################################
    #second route is shown in view mdoe
    assert_select 'div#route_title2', 'splitplace to testplacei2 via changedvia'
    assert_select 'div#fw_t2', "From splitplace to testplacei2"
 
end

#split route with added place
test "split route with added place 199m from route" do
    #create route
  
    #create place at half-way point

    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300, 175.61823472 -41.07 200, 175.61823472 -41.064 100, 175.61823472 -41.06251490 000)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)
#    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450000, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

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
    get '/routes/xrc'+tr.id.to_s+"xpn"

    assert :success
    assert_template 'routes/show_many'

    # route is shown 
    assert_select 'div#route_title1', 'testplace to testplacei2 via splittrack'
    assert_select 'div#actiontitle', 'Enter details of place at which to split this route:'

    pc=Place.count
    post '/places/', place: { name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820185, y: 5450500, projection_id: 2193, location: 'POINT(175.62061295 -41.06696422)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description"}, save: "Save", url: 'xrc'+tr.id.to_s+"xpn"
    #post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'
    
    assert :success
    assert_template 'routes/show_many'
    #new route created
    assert_equal Place.count, pc+1
    assert_equal Route.count, rtcnt+1
    tp=Place.last
    tr2=Route.last
    tr.reload

    assert_select 'div.alert', 'Success: route split. Now please edit the details of the first half of the split route'
    #correct url sequence (modify original, view new)
    assert_select 'input#urlfield[value=?]', 'xrm'+tr.id.to_s+'xrv'+tr2.id.to_s

    ############################################
    #first route is shown in edit mdoe
    #values correct
    assert_select 'input#route_startplace_name[value=?]', 'testplace'
    assert_select 'input#route_endplace_name[value=?]', 'splitplace'
    assert_select 'input#route_distance[value=?]', 560.9776174252318#TODO expected 500

    ############################################
    #second route is shown in view mdoe
    assert_select 'div#route_title1', 'splitplace to testplacei2 via splittrack part 2'
#    assert_select 'span#route_dist1', 'Distance: 0.6 km' #TODO should be 0.5
    assert_select 'div#fw_t1', "From splitplace to testplacei2"

    #updated_by
    assert_equal tr.updatedBy_id, @testuser2.id
    assert_equal tr2.updatedBy_id, @testuser2.id

    #location
    assert_equal tr.location.as_text, "LINESTRING (175.61823472 -41.07151361 300.0, 175.61823472 -41.07 200.0, 175.62061295024048 -41.06696422132981 200.0)"  #calculated from x,y s do not patch those posted 175.62061295 -41.06696422
    assert_equal tr2.location.as_text, "LINESTRING (175.62061295024048 -41.06696422132981 100.0, 175.61823472 -41.064 100.0, 175.61823472 -41.0625149 0.0)"

    #altitude
    assert_equal tr.altloss, 100
    assert_equal tr.altgain, 0
    assert_equal tr.minalt, 200
    assert_equal tr.maxalt, 300
    assert_equal tr2.altloss, 100
    assert_equal tr2.altgain, 0
    assert_equal tr2.minalt, 0
    assert_equal tr2.maxalt, 100

    #instances
    #original route now has 2 instances
    assert_equal tr.routeInstances.count, 2
    assert_equal tr2.routeInstances.count, 1

    #all other values equal
    assert_equal tr.description, tr2.description
    assert_equal tr.routetype_id, tr2.routetype_id
    assert_equal tr.terrain_id, tr2.terrain_id
    assert_equal tr.alpinesummer_id, tr2.alpinesummer_id
    assert_equal tr.river_id, tr2.river_id
    assert_equal tr.alpinewinter_id, tr2.alpinewinter_id
    assert_equal tr.winterdescription, tr2.winterdescription
    assert_equal tr.createdBy_id, tr2.createdBy_id
#    assert_equal tr.created_at, tr2.created_at
    assert_equal tr.via[0..-2], tr2.via[0..-2]
    assert_equal tr.reverse_description, tr2.reverse_description
    assert_equal tr.time, tr2.time
    assert_equal tr.datasource, tr2.datasource
    assert_equal tr.published, tr2.published
    assert_equal tr.experienced_at, tr2.experienced_at

    ############################################
    #save pt1, part 2 placed in edit mode
    patch '/routes/'+tr.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: tp.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.61823472 -41.07151361 300.0, 175.61823472 -41.06701426 300.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "0.5", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: 'xrm'+tr.id.to_s+'xrv'+tr2.id.to_s

    assert :success
    assert_template 'routes/show_many'
    tr.reload

    assert_select 'div.alert', 'First segment updated. Now please update the details of the second part of the split route'
    #correct url sequence (modify original, view new)
    assert_select 'input#urlfield[value=?]', 'xrv'+tr.id.to_s+'xre'+tr2.id.to_s

    ############################################
    #first route is shown in view mdoe
    assert_select 'div#route_title1', 'testplace to splitplace via changedvia'
    assert_select 'div#fw_t1', "From testplace to splitplace"

    ############################################
    #second route is shown in edit mdoe
    #values correct
    assert_select 'input#route_startplace_name[value=?]', 'splitplace'
    assert_select 'input#route_endplace_name[value=?]', 'testplacei2'
    assert_select 'input#route_distance' do |t| end # [value=?]', 0.5008664640973013 #TODO expected 0.500

    ############################################
    #save pt2, part 2 placed in edit moderts 1 and 2 shown as view
    patch '/routes/'+tr2.id.to_s, route: { startplace_id: tp.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.61823472 -41.06701426 200.0, 175.61823472 -41.0625149 200.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "0.5", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: 'xrv'+tr.id.to_s+'xre'+tr2.id.to_s

    assert :success
    assert_template 'routes/show_many'
    tr.reload

    assert_select 'div.alert', 'Route updated, id:'+tr2.id.to_s
    #correct url sequence (modify original, view new)
#    assert_select 'input#urlfield[value=?]', 'xrv'+tr.id.to_s+'xrv'+tr2.id.to_s

    ############################################
    #first route is shown in view mdoe
    assert_select 'div#route_title1', 'testplace to splitplace via changedvia'
    assert_select 'div#fw_t1', "From testplace to splitplace"

    ############################################
    #second route is shown in view mdoe
    assert_select 'div#route_title2', 'splitplace to testplacei2 via changedvia'
    assert_select 'div#fw_t2', "From splitplace to testplacei2"
 
end

#split route with edited place
test "split route with added and edited place 199m from route" do
    #create route
  
    #create place at half-way point

    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300, 175.61823472 -41.07 200, 175.61823472 -41.064 100, 175.61823472 -41.06251490 000)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)
#    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450000, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

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
    get '/routes/xrc'+tr.id.to_s+"xpn"

    assert :success
    assert_template 'routes/show_many'

    # route is shown 
    assert_select 'div#route_title1', 'testplace to testplacei2 via splittrack'
    assert_select 'div#actiontitle', 'Enter details of place at which to split this route:'

    #place >200m from route
    pc=Place.count
    post '/places/', place: { name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820186, y: 5450500, projection_id: 2193, location: 'POINT(175.62061295 -41.06696422)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description"}, save: "Save", url: 'xrc'+tr.id.to_s+"xpn"
    #post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'
    
    assert :success
    assert_template 'routes/show_many'
    #new route created
    assert_equal Place.count, pc+1
    #no new route
    assert_equal Route.count, rtcnt
    tp=Place.last

    assert_select 'div.alert-success', 'New place added, id:'+tp.id.to_s
    assert_select 'div.alert-error', 'Cannot split. Place is &gt;200m from route (200.88954465m). Update the place (below) and save to try again'
    #correct url sequence (split route, edit place)
    assert_select 'input#urlfield[value=?]', 'xrc'+tr.id.to_s+'xpe'+tp.id.to_s

    #place <200m from route
    pc=Place.count
    patch '/places/'+tp.id.to_s, place: { name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820185, y: 5450500, projection_id: 2193, location: 'POINT(175.62061295 -41.06696422)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description"}, save: "Save", url: 'xrc'+tr.id.to_s+"xpe"+tp.id.to_s
    #post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'
    
    assert :success
    assert_template 'routes/show_many'
    #no new place created
    assert_equal Place.count, pc
    #new route created
    assert_equal Route.count, rtcnt+1
    tp=Place.last
    tr2=Route.last
    tr.reload

    assert_select 'div.alert', 'Success: route split. Now please edit the details of the first half of the split route'
    #correct url sequence (modify original, view new)
    assert_select 'input#urlfield[value=?]', 'xrm'+tr.id.to_s+'xrv'+tr2.id.to_s

    ############################################
    #first route is shown in edit mdoe
    #values correct
    assert_select 'input#route_startplace_name[value=?]', 'testplace'
    assert_select 'input#route_endplace_name[value=?]', 'splitplace'
    assert_select 'input#route_distance[value=?]', 560.9776174252318#TODO expected 500

    ############################################
    #second route is shown in view mdoe
    assert_select 'div#route_title1', 'splitplace to testplacei2 via splittrack part 2'
#    assert_select 'span#route_dist1', 'Distance: 0.6 km' #TODO should be 0.5
    assert_select 'div#fw_t1', "From splitplace to testplacei2"

    #updated_by
    assert_equal tr.updatedBy_id, @testuser2.id
    assert_equal tr2.updatedBy_id, @testuser2.id

    #location
    assert_equal tr.location.as_text, "LINESTRING (175.61823472 -41.07151361 300.0, 175.61823472 -41.07 200.0, 175.62061295024048 -41.06696422132981 200.0)"  #calculated from x,y s do not patch those posted 175.62061295 -41.06696422
    assert_equal tr2.location.as_text, "LINESTRING (175.62061295024048 -41.06696422132981 100.0, 175.61823472 -41.064 100.0, 175.61823472 -41.0625149 0.0)"

    #altitude
    assert_equal tr.altloss, 100
    assert_equal tr.altgain, 0
    assert_equal tr.minalt, 200
    assert_equal tr.maxalt, 300
    assert_equal tr2.altloss, 100
    assert_equal tr2.altgain, 0
    assert_equal tr2.minalt, 0
    assert_equal tr2.maxalt, 100

    #instances
    #original route now has 2 instances
    assert_equal tr.routeInstances.count, 2
    assert_equal tr2.routeInstances.count, 1

    #all other values equal
    assert_equal tr.description, tr2.description
    assert_equal tr.routetype_id, tr2.routetype_id
    assert_equal tr.terrain_id, tr2.terrain_id
    assert_equal tr.alpinesummer_id, tr2.alpinesummer_id
    assert_equal tr.river_id, tr2.river_id
    assert_equal tr.alpinewinter_id, tr2.alpinewinter_id
    assert_equal tr.winterdescription, tr2.winterdescription
    assert_equal tr.createdBy_id, tr2.createdBy_id
#    assert_equal tr.created_at, tr2.created_at
    assert_equal tr.via[0..-2], tr2.via[0..-2]
    assert_equal tr.reverse_description, tr2.reverse_description
    assert_equal tr.time, tr2.time
    assert_equal tr.datasource, tr2.datasource
    assert_equal tr.published, tr2.published
    assert_equal tr.experienced_at, tr2.experienced_at

    ############################################
    #save pt1, part 2 placed in edit mode
    patch '/routes/'+tr.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: tp.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.61823472 -41.07151361 300.0, 175.61823472 -41.06701426 300.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "0.5", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: 'xrm'+tr.id.to_s+'xrv'+tr2.id.to_s

    assert :success
    assert_template 'routes/show_many'
    tr.reload

    assert_select 'div.alert', 'First segment updated. Now please update the details of the second part of the split route'
    #correct url sequence (modify original, view new)
    assert_select 'input#urlfield[value=?]', 'xrv'+tr.id.to_s+'xre'+tr2.id.to_s

    ############################################
    #first route is shown in view mdoe
    assert_select 'div#route_title1', 'testplace to splitplace via changedvia'
    assert_select 'div#fw_t1', "From testplace to splitplace"

    ############################################
    #second route is shown in edit mdoe
    #values correct
    assert_select 'input#route_startplace_name[value=?]', 'splitplace'
    assert_select 'input#route_endplace_name[value=?]', 'testplacei2'
    assert_select 'input#route_distance' do |t| end # [value=?]', 0.5008664640973013 #TODO expected 0.500

    ############################################
    #save pt2, part 2 placed in edit moderts 1 and 2 shown as view
    patch '/routes/'+tr2.id.to_s, route: { startplace_id: tp.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.61823472 -41.06701426 200.0, 175.61823472 -41.0625149 200.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "0.5", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: 'xrv'+tr.id.to_s+'xre'+tr2.id.to_s

    assert :success
    assert_template 'routes/show_many'
    tr.reload

    assert_select 'div.alert', 'Route updated, id:'+tr2.id.to_s
    #correct url sequence (modify original, view new)
#    assert_select 'input#urlfield[value=?]', 'xrv'+tr.id.to_s+'xrv'+tr2.id.to_s

    ############################################
    #first route is shown in view mdoe
    assert_select 'div#route_title1', 'testplace to splitplace via changedvia'
    assert_select 'div#fw_t1', "From testplace to splitplace"

    ############################################
    #second route is shown in view mdoe
    assert_select 'div#route_title2', 'splitplace to testplacei2 via changedvia'
    assert_select 'div#fw_t2', "From splitplace to testplacei2"
 
end

#split route with edited place
test "cannot split route with selected place >200 from route" do
    #create route
  
    #create place at half-way point

    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300, 175.61823472 -41.07 200, 175.61823472 -41.064 100, 175.61823472 -41.06251490 000)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)
#    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450000, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")
    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820186, y: 5450500, projection_id: 2193, location: 'POINT(175.62062484 -41.06696395)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

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
    pc=Place.count
    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    #post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'
    
    assert :success
    assert_template 'routes/show_many'
    #no new place
    assert_equal Place.count, pc
    #no new route
    assert_equal Route.count, rtcnt

    assert_select 'div.alert-error', 'Cannot split. Place is &gt;200m from route (200.889527002m). Update the place (below) and save to try again'
    # route is shown 
    assert_select 'div#route_title1', 'testplace to testplacei2 via splittrack'
    assert_select 'div#actiontitle2', 'Select place at which to split this route:'
end

#forward trip has new route segments .... pt1, pt2, ...
test "route used forwards in trip" do
    #create route

    #create place at half-way point

    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450500, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

    tt=Trip.create(name: "splittrip", createdBy_id: @testuser.id, description:"split route description", published: true)
    td1=TripDetail.create(trip_id: tt.id, place_id: @testplace.id, order: 1)
    td2=TripDetail.create(trip_id: tt.id, route_id: tr.id, order: 2)
    td3=TripDetail.create(trip_id: tt.id, place_id: @testplace2.id, order: 3)

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
    tcnt=Trip.count
    tdcnt=TripDetail.count
    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'
    assert :success
    assert_template 'routes/show_many'
    #new route created
    assert_equal Route.count, rtcnt+1
    tr2=Route.last
    tr.reload

    #new trip detail created
    assert_equal Trip.count, tcnt
    assert_equal TripDetail.count, tdcnt+1

    tdnew=TripDetail.last
    td1.reload
    td2.reload
    td3.reload

    assert_equal td1.trip_id, tt.id
    assert_equal td2.trip_id, tt.id
    assert_equal tdnew.trip_id, tt.id
    assert_equal td3.trip_id, tt.id

    assert_equal td1.place_id, @testplace.id
    assert_equal td2.route_id, tr.id
    assert_equal tdnew.route_id, tr2.id
    assert_equal td3.place_id, @testplace2.id

    assert_equal td1.order, 1
    assert_equal td2.order, 2
    assert_equal tdnew.order, 3
    assert_equal td3.order, 4
end
#reverse trip has new route segments .... -pt2, -pt1, ...
test "route used backwards in trip" do
    #create route

    #create place at half-way point

    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450500, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

    tt=Trip.create(name: "splittrip", createdBy_id: @testuser.id, description:"split route description", published: true)
    td1=TripDetail.create(trip_id: tt.id, place_id: @testplace.id, order: 1)
    td2=TripDetail.create(trip_id: tt.id, route_id: -tr.id, order: 2)
    td3=TripDetail.create(trip_id: tt.id, place_id: @testplace2.id, order: 3)

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
    tcnt=Trip.count
    tdcnt=TripDetail.count
    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'
    assert :success
    assert_template 'routes/show_many'
    #new route created
    assert_equal Route.count, rtcnt+1
    tr2=Route.last
    tr.reload

    #new trip detail created
    assert_equal Trip.count, tcnt
    assert_equal TripDetail.count, tdcnt+1

    tdnew=TripDetail.last
    td1.reload
    td2.reload
    td3.reload

    assert_equal td1.trip_id, tt.id
    assert_equal tdnew.trip_id, tt.id
    assert_equal td2.trip_id, tt.id
    assert_equal td3.trip_id, tt.id

    assert_equal td1.place_id, @testplace.id
    assert_equal tdnew.route_id, -tr2.id
    assert_equal td2.route_id, -tr.id
    assert_equal td3.place_id, @testplace2.id

    assert_equal td1.order, 1
    assert_equal tdnew.order, 2
    assert_equal td2.order, 3
    assert_equal td3.order, 4
end

#linked items inherit both segments
# base linked item
test "base linked items inherit both parts" do
    #create route

    #create place at half-way point

    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450500, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

    tbl1=Link.create(item_id:@testroute.id, item_type: 'route', baseItem_id:tr.id, baseItem_type: "route", item_url: nil )
    til1=Link.create(item_id:tr.id, item_type: 'route', baseItem_id:@testplace.id, baseItem_type: "place", item_url: nil )
    tbl2=Link.create(item_id:nil, item_type: 'URL', item_url: "http://google.com", baseItem_id:tr.id, baseItem_type: "route")

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
    tcnt=Link.count
    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'
    assert :success
    assert_template 'routes/show_many'
    #new route created
    assert_equal Route.count, rtcnt+1
    tr2=Route.last
    tr.reload
    tbl1b=Link.all[-3]
    til1b=Link.all[-2]
    tbl2b=Link.all[-1]

    #new link created for each of 3 above
    assert_equal Link.count, tcnt+3
    assert_equal tbl1b.baseItem_id, tr2.id
    assert_equal tbl1b.baseItem_type, 'route'
    assert_equal tbl1b.item_id, @testroute.id
    assert_equal tbl1b.item_type, 'route'
    assert_equal tbl1b.item_url, nil
     
    assert_equal til1b.baseItem_id, @testplace.id
    assert_equal til1b.baseItem_type, 'place'
    assert_equal til1b.item_id, tr2.id
    assert_equal til1b.item_type, 'route'
    assert_equal til1b.item_url, nil

    assert_equal tbl2b.baseItem_id, tr2.id
    assert_equal tbl2b.baseItem_type, 'route'
    assert_equal tbl2b.item_id, nil
    assert_equal tbl2b.item_type, 'URL'
    assert_equal tbl2b.item_url, "http://google.com"
end

#errors:
##Distance > 200m - done
##Split returned 1 segment (split at endplace)
test "Fail case - split route returns one segment" do
    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450000, projection_id: 2193, location: 'POINT(175.61823472 -41.07151361)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")

    #split at selected place
    rtcnt=Route.count
    pc=Place.count
    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    #post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    assert :success
    assert_template 'routes/show_many'
    #no new place
    assert_equal Place.count, pc
    #no new route
    assert_equal Route.count, rtcnt

    assert_select 'div.alert-error', 'Fewer than 2 segments resulted from split. Update the place (below) and save to try again'

end

##Start segment length=0
##End segment length=0
##Save of new route failed (validation errors) (duplicate name a good one)
test "Fail case - cannot save new route" do
    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450500, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")
    dr=Route.create(name: "", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: tp.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack part 2", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    #split at selected place
    rtcnt=Route.count
    pc=Place.count
    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    #post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    assert :success
    assert_template 'routes/show_many'
    #no new place
    assert_equal Place.count, pc
    #no new route
    assert_equal Route.count, rtcnt

    assert_select 'div.alert-error', 'Failed to save new route - {:name=&gt;[&quot;has already been taken&quot;]}. Update the place (below) and save to try again'

end

##Save of old route fails (dupicate name a good one)
test "Fail case - cannot save old route" do
    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    tr=Route.create(name: "splitroute", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: @testplace2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    tp=Place.create(name: "splitplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 1820000, y: 5450500, projection_id: 2193, location: 'POINT(175.61823472 -41.06701426)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")
    dr=Route.create(name: "", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace.id, endplace_id: tp.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "splittrack part 1", importance_id: 2, time: 3, location: 'LINESTRING(175.61823472 -41.07151361 300,175.61823472 -41.06251490 200)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)

    #split at selected place
    rtcnt=Route.count
    pc=Place.count
    post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    #post '/places/select', url: 'xrc'+tr.id.to_s+'xps', route_startplace_id: tp.id.to_s, commit: 'select'

    assert :success
    assert_template 'routes/show_many'
    #no new place
    assert_equal Place.count, pc
    #no new route
    assert_equal Route.count, rtcnt

    assert_select 'div.alert-error', 'Failed to update old route - {:name=&gt;[&quot;has already been taken&quot;]}. Update the place (below) and save to try again'

end


##Copy link fails (how???) - no validation
##Create tripdetail (forwards) fails - validation on trips_id, order
##Create tripdetail (backwards) fails - validation on trips_id, order
##Update existing tripdetail fails


end
