require 'test_helper'

class RoutesEditTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "view edit single route as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/'+@testroute.id.to_s+'/edit'
    assert :success
    assert_template 'routes/edit'

    #display
    assert_select "input#route_startplace_name[value=?]",  "testplacei3"
    assert_select 'input#route_startplace_name[disabled="disabled"]'
    assert_select "input#route_endplace_name[value=?]",  "testplacei4"
    assert_select 'input#route_endplace_name[disabled="disabled"]'
    assert_select "input#route_via[value=?]",  "track1"
    assert_select "input#route_experienced_at[value=?]",  "1900-01-01"
    assert_select "input#route_location[value=?]",  "LINESTRING (175.0 -49.0 300.0, 177.0 -49.0 400.0)"
    assert_select 'option[value="Drawn on map"]' do |t|
       assert_select %q{option[selected="&quot;selected&quot;"]}
    end

    assert_select "textarea#route_description",  "A"*1000
    assert_select "textarea#route_reverse_description",  "Z"*1000
    assert_select "input#route_time[value=?]",  "3.0"
    assert_select "input#route_distance[value=?]", "1.0"
    assert_select 'input#route_distance[readonly="readonly"]'
    assert_select "input#route_importance[value=?]", "2"
    assert_select "div#importance_name", "Primary, unmapped"
    assert_select "div#importance_text", "Route not on maps, but is principal access to hut or along range / catchment"
    assert_select "input#route_type[value=?]", "2"
    assert_select "div#rt_name", "Road"
    assert_select "div#rt_text", "Formed road, 4WD track, etc"

    assert_select "input#gradient[value=?]", "2"
    assert_select "div#gradient_name", "Flat"
    assert_select "div#gradient_text", "Flat"

    assert_select "input#terrain[value=?]", "2"
    assert_select "div#terr_name", "Easy"
    assert_select "div#terr_text", "Grass / prepared surface"

    assert_select "input#alpinesummer[value=?]", "2"
    assert_select "div#alps_name", "None"
    assert_select "div#alps_text", "No alpine skills required"

    assert_select "input#river[value=?]", "2"
    assert_select "div#river_name", "None"
    assert_select "div#river_text", "No unbridged river crossings"

    assert_select "input#alpinewinter[value=?]", "2"
    assert_select "div#alpw_name", "None"
    assert_select "div#alpw_text", "No alpine skills required"

    assert_select "textarea#route_winterdescription",  "X"*1000
    assert_select "input#route_published[value=?]", "1"
   
end
test "view edit single route reverse as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/-'+@testroute.id.to_s+'/edit'
    assert :success
    assert_template 'routes/edit'

    #display
    assert_select "input#route_startplace_name[value=?]",  "testplacei4"
    assert_select 'input#route_startplace_name[disabled="disabled"]'
    assert_select "input#route_endplace_name[value=?]",  "testplacei3"
    assert_select 'input#route_endplace_name[disabled="disabled"]'
    assert_select "input#route_via[value=?]",  "track1"
    assert_select "input#route_experienced_at[value=?]",  "1900-01-01"
    assert_select "input#route_location[value=?]",  "LINESTRING (177.0 -49.0 400.0, 175.0 -49.0 300.0)"
    assert_select 'option[value="Drawn on map"]' do |t|
       assert_select %q{option[selected="&quot;selected&quot;"]}
    end

    assert_select "textarea#route_description",  "Z"*1000
    assert_select "textarea#route_reverse_description",  "A"*1000
    assert_select "input#route_time[value=?]",  "3.0"
    assert_select "input#route_distance[value=?]", "1.0"
    assert_select 'input#route_distance[readonly="readonly"]'
    assert_select "input#route_importance[value=?]", "2"
    assert_select "div#importance_name", "Primary, unmapped"
    assert_select "div#importance_text", "Route not on maps, but is principal access to hut or along range / catchment"
    assert_select "input#route_type[value=?]", "2"
    assert_select "div#rt_name", "Road"
    assert_select "div#rt_text", "Formed road, 4WD track, etc"

    assert_select "input#gradient[value=?]", "2"
    assert_select "div#gradient_name", "Flat"
    assert_select "div#gradient_text", "Flat"

    assert_select "input#terrain[value=?]", "2"
    assert_select "div#terr_name", "Easy"
    assert_select "div#terr_text", "Grass / prepared surface"

    assert_select "input#alpinesummer[value=?]", "2"
    assert_select "div#alps_name", "None"
    assert_select "div#alps_text", "No alpine skills required"

    assert_select "input#river[value=?]", "2"
    assert_select "div#river_name", "None"
    assert_select "div#river_text", "No unbridged river crossings"

    assert_select "input#alpinewinter[value=?]", "2"
    assert_select "div#alpw_name", "None"
    assert_select "div#alpw_text", "No alpine skills required"

    assert_select "textarea#route_winterdescription",  "X"*1000
    assert_select "input#route_published[value=?]", "1"
   
end

test "edit single route as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 93.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/show'

    #display
    @testroute.reload
    routetitle=@testroute.startplace.name+" to "+@testroute.endplace.name+" via "+@testroute.via
    assert_select "div#route_title1", /#{routetitle}.*/
    assert_select "span#route_dist1", "Distance: 2.2 km"
    assert_select "span#route_time1", "(1.1 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 90m to 93m.  Gain: 3m.  Loss: 0m"
    assert_select "span#route_grad1", ".  Gradient: 0 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Surfaced walkway.*/}
    assert_select "span#route_terr1", /.*Easy-moderate terrain.*/
    assert_select "span#gradien_smry1", /.*Gentle.*/
    assert_select "span#alpines_smry1", /.*Alpine weather.*/ 
    assert_select "span#alpinew_smry1", /.*Snow\/ice underfoot.*/
    assert_select "span#rivers_smry1",  /.*Streams.*/

    #detailed stats
    assert_select "span#type_text1", "Surfaced walkway"
    assert_select "span#impo_text1", "Secondary, mapped"
    assert_select "span#grad_text1", "Gentle"
    assert_select "span#terr_text1", "Easy-moderate"
    assert_select "span#alps_text1", "Alpine weather"
    assert_select "span#rive_text1", "Streams"
    assert_select "span#alpw_text1", "Snow/ice underfoot"


    #main rouite details
    assert_select "div#gpx1", "GPX info source: Uploaded from GPS"
    assert_select "div#fw_r1", "M"*3000
    assert_select "span#rv_d1", "N"*3000
    assert_select "span#winterdesc1", "O"*3000
    assert_select "div#fw_t1", "From "+@testroute.startplace.name+" to "+@testroute.endplace.name
    assert_select "div#rv_t1", "From "+@testroute.endplace.name+" to "+@testroute.startplace.name

    assert_select "div#links_section"

    assert_select "div#comments_section"

    #download gpx enabled
    assert_select "a[href=?]", '/routes/'+@testroute.id.to_s+'.gpx'+"?version="+@testroute.routeInstances.last.id.to_s

    #edit disabled
    assert_select  "span#editbutton", false
 
end

#edit single route reverse as user
test "edit single route reverse as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    patch '/routes/-'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/show'

    #display
    @testroute.reload
    routetitle=@testroute.endplace.name+" to "+@testroute.startplace.name+" via "+@testroute.via
    assert_select "div#route_title1", /#{routetitle}.*/
    assert_select "span#route_dist1", "Distance: 2.2 km"
    assert_select "span#route_time1", "(1.1 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 90m to 96m.  Gain: 6m.  Loss: 0m"
    assert_select "span#route_grad1", ".  Gradient: 0 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Surfaced walkway.*/}
    assert_select "span#route_terr1", /.*Easy-moderate terrain.*/
    assert_select "span#gradien_smry1", /.*Gentle.*/
    assert_select "span#alpines_smry1", /.*Alpine weather.*/ 
    assert_select "span#alpinew_smry1", /.*Snow\/ice underfoot.*/
    assert_select "span#rivers_smry1",  /.*Streams.*/

    #detailed stats
    assert_select "span#type_text1", "Surfaced walkway"
    assert_select "span#impo_text1", "Secondary, mapped"
    assert_select "span#grad_text1", "Gentle"
    assert_select "span#terr_text1", "Easy-moderate"
    assert_select "span#alps_text1", "Alpine weather"
    assert_select "span#rive_text1", "Streams"
    assert_select "span#alpw_text1", "Snow/ice underfoot"


    #main rouite details
    assert_select "div#gpx1", "GPX info source: Uploaded from GPS"
    assert_select "div#fw_r1", "M"*3000
    assert_select "span#rv_d1", "N"*3000
    assert_select "span#winterdesc1", "O"*3000
    assert_select "div#fw_t1", "From "+@testroute.endplace.name+" to "+@testroute.startplace.name
    assert_select "div#rv_t1", "From "+@testroute.startplace.name+" to "+@testroute.endplace.name

    assert_select "div#links_section"

    assert_select "div#comments_section"

    #download gpx enabled
    assert_select "a[href=?]", '/routes/-'+@testroute.id.to_s+'.gpx'+"?version="+@testroute.routeInstances.last.id.to_s

    #edit disabled
    assert_select  "span#editbutton", false
 
end

#edit someones elses route as user
test "view edit single route as not-creating-user" do
    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    get '/routes/'+@testroute.id.to_s+'/edit'
    assert :success
    assert_template 'routes/edit'

    #experienced has been reset
    assert_select "input#route_experienced_at"
    assert_select "input#route_experienced_at[value=?]", /.*/,  false
end

#new single route ad user
test "create single route as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    rtcnt=Route.count

    post '/routes', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 93.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/show'

    #display
    newroute=Route.last
    assert_equal Route.count, rtcnt+1 
    routetitle=@testplace.name+" to "+@testplace2.name+" via changedvia"
    assert_select "div#route_title1", /#{routetitle}.*/
    assert_select "span#route_dist1", "Distance: 2.2 km"
    assert_select "span#route_time1", "(1.1 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 90m to 93m.  Gain: 3m.  Loss: 0m"
    assert_select "span#route_grad1", ".  Gradient: 0 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Surfaced walkway.*/}
    assert_select "span#route_terr1", /.*Easy-moderate terrain.*/
    assert_select "span#gradien_smry1", /.*Gentle.*/
    assert_select "span#alpines_smry1", /.*Alpine weather.*/ 
    assert_select "span#alpinew_smry1", /.*Snow\/ice underfoot.*/
    assert_select "span#rivers_smry1",  /.*Streams.*/

    #detailed stats
    assert_select "span#type_text1", "Surfaced walkway"
    assert_select "span#impo_text1", "Secondary, mapped"
    assert_select "span#grad_text1", "Gentle"
    assert_select "span#terr_text1", "Easy-moderate"
    assert_select "span#alps_text1", "Alpine weather"
    assert_select "span#rive_text1", "Streams"
    assert_select "span#alpw_text1", "Snow/ice underfoot"


    #main rouite details
    assert_select "div#gpx1", "GPX info source: Uploaded from GPS"
    assert_select "div#fw_r1", "M"*3000
    assert_select "span#rv_d1", "N"*3000
    assert_select "span#winterdesc1", "O"*3000
    assert_select "div#fw_t1", "From "+@testplace.name+" to "+@testplace2.name
    assert_select "div#rv_t1", "From "+@testplace2.name+" to "+@testplace.name

    assert_select "div#links_section"

    assert_select "div#comments_section"

    #download gpx enabled
    assert_select "a[href=?]", '/routes/'+newroute.id.to_s+'.gpx'+"?version="+newroute.routeInstances.last.id.to_s

    #edit disabled
    assert_select  "span#editbutton", false
 
end

#edit invalid route
test "edit nonexistant route" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/999/edit'
    assert :success
    follow_redirect!
    assert_template 'routes/leg_index'

    get '/routes/-999/edit'
    assert :success
    follow_redirect!
    assert_template 'routes/leg_index'

end
# cannot edit as stranger, guest
test "cannot edit route as stranger" do
    get '/routes/'+@testroute.id.to_s+'/edit'
    assert :success
    follow_redirect!
    assert_template 'sessions/new'

    #update as stranger
    tr=@testroute
    patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'sessions/new'

    @testroute.reload
    assert_equal tr, @testroute


    #create as stranger
    rtcnt=Route.count

    post '/routes', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 93.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'sessions/new'

    assert_equal rtcnt, Route.count

end

# cannot edit as stranger, guest
test "cannot edit route as guest" do
   add_route_to_trip_fw(@testroute)
   assert is_guest?


    get '/routes/'+@testroute.id.to_s+'/edit'
    assert :success
    follow_redirect!
    assert_template 'sessions/new'

    #update as stranger
    tr=@testroute
    patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'sessions/new'

    @testroute.reload
    assert_equal tr, @testroute


    #create as stranger
    rtcnt=Route.count

    post '/routes', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 93.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'sessions/new'

    assert_equal rtcnt, Route.count
end

# handle parameter errors edit
test "handle mandatory parameter errors in edit route" do
  #navigate to my route
  login_as(@testuser2.name,"password")
  assert is_logged_in?

  #MANDATORY (published)
  tr=@testroute
  # no from
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: "", endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Startplace can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute

  # no to 
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: "", via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Endplace can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute
  # no via
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Via can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute

  #MANDATORY (draft)
  # no from
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: "", endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Startplace can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute

  # no to 
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: "", via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Endplace can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute
  # no via
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Via can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute
end

test "handle required-for-publication errors in edit route" do

  #navigate to my route
  login_as(@testuser2.name,"password")
  assert is_logged_in?

  #REQUIRED FOR PUBLICATION
  # time
    tr=@testroute
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Time can&#39;t be blank for a published route"
    @testroute.reload
    assert_equal tr, @testroute

  # neither description 
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "", reverse_description: "", time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Description or Reverse description is required for a published route"
    @testroute.reload
    assert_equal tr, @testroute

  # location
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Location can&#39;t be blank for a published route"
    @testroute.reload
    assert_equal tr, @testroute


  # date experienced
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/edit'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Experienced at can&#39;t be blank for a published route"
    @testroute.reload
    assert_equal tr, @testroute


  # NOT REQUIRED FOR DRAFT
  # allows one descriptiondd
  # time
  # neither description 
  # location
  # date experienced
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "", location: "", description: "", reverse_description: "", time: "", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/show'
    @testroute.reload
    assert_equal @testroute.experienced_at, nil
    assert_equal @testroute.location, nil
    assert_equal @testroute.description, ""
    assert_equal @testroute.reverse_description, ""

end

# handle parameter errors new

test "handle mandatory parameter errors in new route" do
  #navigate to my route
  login_as(@testuser2.name,"password")
  assert is_logged_in?

  #MANDATORY (published)
  tr=Route.count
  # no from
  post '/routes/', route: { startplace_id: "", endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Startplace can&#39;t be blank"
    assert_equal tr, Route.count

  # no to 
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: "", via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Endplace can&#39;t be blank"
    assert_equal tr, Route.count
  # no via
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Via can&#39;t be blank"
    assert_equal tr, Route.count

  #MANDATORY (draft)
  # no from
  post '/routes/', route: { startplace_id: "", endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Startplace can&#39;t be blank"
    assert_equal tr, Route.count

  # no to 
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: "", via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Endplace can&#39;t be blank"
    assert_equal tr, Route.count
  # no via
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Via can&#39;t be blank"
    assert_equal tr, Route.count
end
test "handle required-for-publication errors in new route" do

  #navigate to my route
  login_as(@testuser2.name,"password")
  assert is_logged_in?

  #REQUIRED FOR PUBLICATION
  # time
    tr=Route.count
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Time can&#39;t be blank for a published route"
    assert_equal tr, Route.count

  # neither description 
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "", reverse_description: "", time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Description or Reverse description is required for a published route"
    assert_equal tr, Route.count

  # location
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Location can&#39;t be blank for a published route"
    assert_equal tr, Route.count


  # date experienced
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/new'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Experienced at can&#39;t be blank for a published route"
    assert_equal tr, Route.count


  # NOT REQUIRED FOR DRAFT
  # allows one descriptiondd
  # time
  # neither description 
  # location
  # date experienced
  post '/routes/', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "", location: "", description: "", reverse_description: "", time: "", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save"

    assert :success
    assert_template 'routes/show'
    tr=Route.last
    assert_equal tr.experienced_at, nil
    assert_equal tr.location, nil
    assert_equal tr.description, ""
    assert_equal tr.reverse_description, ""

end
end


