require 'test_helper'

class RoutesEditmanyTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "view edit many route as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/xre'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'

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
test "view edit many route reverse as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/xre-'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'

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

test "edit many route as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 93.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save", url:'xre'+@testroute.id.to_s

    assert :success
    assert_template 'routes/show_many'

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

    #download gpx enabled
    assert_select "a[href=?]", '/routes/xrv'+@testroute.id.to_s+'.gpx'

    #edit enabled
    assert_select "a#editbutton"
    assert_select "span#edit1"
 
end

#edit single route reverse as user
test "edit many route reverse as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    patch '/routes/-'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save", url: "xre-"+@testroute.id.to_s

    assert :success
    assert_template 'routes/show_many'

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

    #download gpx enabled
    assert_select "a[href=?]", '/routes/xrv-'+@testroute.id.to_s+'.gpx'

    #edit enabled
    assert_select "a#editbutton"
    assert_select "span#edit1"
 
end

#edit someones elses route as user
test "view many single route as not-creating-user" do
    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    get '/routes/xre'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'

    #experienced has been reset
    assert_select "input#route_experienced_at"
    assert_select "input#route_experienced_at[value=?]", /.*/,  false
end

#new single route ad user
test "create many route as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    rtcnt=Route.count

    post '/routes', route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 93.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "0" }, datasource: "Uploaded from GPS", save: "Save", url: "xpv"+@testplace.id.to_s+"xrn"

    assert :success
    assert_template 'routes/show_many'

    #display
    newroute=Route.last
    assert_equal Route.count, rtcnt+1 
    routetitle=@testplace.name+" to "+@testplace2.name+" via changedvia"
    assert_select "div#route_title2", /#{routetitle}.*/
    assert_select "span#route_dist2", "Distance: 2.2 km"
    assert_select "span#route_time2", "(1.1 DOC hours)"
    assert_select "span#route_alti2", "Altitude: 90m to 93m.  Gain: 3m.  Loss: 0m"
    assert_select "span#route_grad2", ".  Gradient: 0 deg"
    assert_select "span#route_type2", {:count =>1, :text=> /.*Surfaced walkway.*/}
    assert_select "span#route_terr2", /.*Easy-moderate terrain.*/
    assert_select "span#gradien_smry2", /.*Gentle.*/
    assert_select "span#alpines_smry2", /.*Alpine weather.*/ 
    assert_select "span#alpinew_smry2", /.*Snow\/ice underfoot.*/
    assert_select "span#rivers_smry2",  /.*Streams.*/

    #detailed stats
    assert_select "span#type_text2", "Surfaced walkway"
    assert_select "span#impo_text2", "Secondary, mapped"
    assert_select "span#grad_text2", "Gentle"
    assert_select "span#terr_text2", "Easy-moderate"
    assert_select "span#alps_text2", "Alpine weather"
    assert_select "span#rive_text2", "Streams"
    assert_select "span#alpw_text2", "Snow/ice underfoot"


    #main rouite details
    assert_select "div#gpx2", "GPX info source: Uploaded from GPS"
    assert_select "div#fw_r2", "M"*3000
    assert_select "span#rv_d2", "N"*3000
    assert_select "span#winterdesc2", "O"*3000
    assert_select "div#fw_t2", "From "+@testplace.name+" to "+@testplace2.name
    assert_select "div#rv_t2", "From "+@testplace2.name+" to "+@testplace.name

    #no gpx in new route
    assert_select "a[href=?]", /xpv#{@testplace.id.to_s}xrv.*gpx/, false

    #select next place endbled
    assert_select "div#actiontitle3", "Select next place on route:"

    #edit enabled
    assert_select "span#edit1"
    assert_select "span#edit2"
 
end

#edit invalid route
test "edit_many nonexistant route" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/xre999'
    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#route_title1', false

    get '/routes/xre-999'
    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#route_title1', false

    get '/routes/xrm999'
    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#route_title1', false

    get '/routes/xrm-999'
    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#route_title1', false
end

# cannot edit as stranger, guest
test "cannot editmany route as stranger" do
    get '/routes/xre'+@testroute.id.to_s
    assert :success
    #show_many screen but no edit form
    assert_template 'routes/show_many'
    assert_select 'div#route_title1', false
end

test "cannot editmany route as guest" do
   add_route_to_trip_fw(@testroute)
   assert is_guest?


    get '/routes/xre'+@testroute.id.to_s
    assert :success
    #show_many screen but no edit form
    assert_template 'routes/show_many'
    assert_select 'div#route_title1', false
end



# parameter errors and validations
test "handle mandatory parameter errors in editmany route" do
  #navigate to my route
  login_as(@testuser2.name,"password")
  assert is_logged_in?

  #MANDATORY (published)
  tr=@testroute
  thisurl="xpv"+@testplace.id.to_s+"xre"+@testroute.id.to_s+"xrv"+@testroute2.id.to_s
  # no from
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: "", endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Startplace can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute
    assert_select "input#urlfield[value=?]", thisurl
end

test "handle required-for-publication errors in editmany route" do

  thisurl="xpv"+@testplace.id.to_s+"xre"+@testroute.id.to_s+"xrv"+@testroute2.id.to_s
  #navigate to my route
  login_as(@testuser2.name,"password")
  assert is_logged_in?

  #REQUIRED FOR PUBLICATION
  # time
    tr=@testroute
  patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Time can&#39;t be blank for a published route"
    @testroute.reload
    assert_equal tr, @testroute
    assert_select "input#urlfield[value=?]", thisurl
end
#TODO: partial routes
test "edit a partial route" do
  login_as(@testuser.name,"password")
  assert is_logged_in?

#check edit link is correct
    get '/routes/xrv'+@testroute2.id.to_s+'xqv'+@testroute.id.to_s+'y'+@testplace.id.to_s+'y'+@testplace2.id.to_s+'xrv'+@testroute3.id.to_s
    assert :success
    assert_template 'routes/show_many'

    #edit link
    assert_select "span#edit2>a#editbutton[href=?]", 'xrv'+@testroute2.id.to_s+'xqe'+@testroute.id.to_s+'y'+@testplace.id.to_s+'y'+@testplace2.id.to_s+'xrv'+@testroute3.id.to_s


#edit - correct details shown
    thisurl='/routes/xrv'+@testroute2.id.to_s+'xqe'+@testroute.id.to_s+'y'+@testplace.id.to_s+'y'+@testplace2.id.to_s+'xrv'+@testroute3.id.to_s
    get thisurl
    assert :success
    assert_template 'routes/show_many'

    #display shows full route (ot partial bit we use)
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

#save with errors - redisplay correctly with changes and error messages
    #mandatory
    tr=@testroute
    patch '/routes/'+@testroute.id.to_s, route: { startplace_id: "", endplace_id: @testplace2.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Startplace can&#39;t be blank"
    @testroute.reload
    assert_equal tr, @testroute
    assert_select "input#urlfield[value=?]", thisurl
    
    #required-for-publication
    patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace.id.to_s, endplace_id: @testplace2.id.to_s, via: "newvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: thisurl
    assert :success
    assert_template 'routes/show_many'
    assert_select "div.alert-error", "Enter the required information and save again, or uncheck &#39;published&#39; if you wish to save this as a draft version without this information"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Time can&#39;t be blank for a published route"
    @testroute.reload
    assert_equal tr, @testroute
    assert_select "input#urlfield[value=?]", thisurl

#save - saved correctly
    patch '/routes/'+@testroute.id.to_s, route: { startplace_id: @testplace3.id.to_s, endplace_id: @testplace4.id.to_s, via: "changedvia", experienced_at: "2015-01-01", location: "LINESTRING (175.29328274238836 -41.53084479196681 90.0, 175.29534267891307 -41.53065203340396 96.0)", description: "M"*3000, reverse_description: "N"*3000, time: "1.1", distance: "2.2", importance_id: "3", routetype_id: "3", gradient_id: "3", terrain_id: "3", alpinesummer_id: "3", river_id: "3", alpinewinter_id: "3", winterdescription: "O"*3000, published: "1" }, datasource: "Uploaded from GPS", save: "Save", url: thisurl
    assert :success
    assert_template 'routes/show_many'

    #still shows partail route endpoints
    routetitle=@testplace.name+" to "+@testplace2.name+" via changedvia"
    assert_select "div#route_title2", /#{routetitle}.*/
    #and correct details fro full route
    assert_select "span#route_dist2", "Distance: 2.2 km"
    assert_select "span#route_time2", "(1.1 DOC hours)"
    assert_select "span#route_alti2", "Altitude: 90m to 96m.  Gain: 6m.  Loss: 0m"
    assert_select "span#route_grad2", ".  Gradient: 0 deg"
    assert_select "span#route_type2", {:count =>1, :text=> /.*Surfaced walkway.*/}
    assert_select "span#route_terr2", /.*Easy-moderate terrain.*/
    assert_select "span#gradien_smry2", /.*Gentle.*/
    assert_select "span#alpines_smry2", /.*Alpine weather.*/
    assert_select "span#alpinew_smry2", /.*Snow\/ice underfoot.*/
    assert_select "span#rivers_smry2",  /.*Streams.*/

#user returned to correct through route
    assert_select "div#route_title1", /testplacei4 to testplace via track2.*/
    assert_select "div#route_title3", /testplacei4 to testplace via track3.*/
    assert_select "div#route_title4", false



end

#TODO: url sequences - separate test


end


