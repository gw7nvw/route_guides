require 'test_helper'

class TripsEditTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "edit our trip as guest" do
   add_route_to_trip_rv(@testroute)
   add_route_to_trip_fw(@testroute2)
   add_place_to_trip(@testplace)
   @ourguest=Guest.find_by_id(session[:guest_id])

   assert is_guest?
   trip=@ourguest.currenttrip_id
   assert td1=(TripDetail.find_by_sql [" select * from trip_details where trip_id = ?", trip])[0]
   assert td2=(TripDetail.find_by_sql [" select * from trip_details where trip_id = ?", trip])[1]
   assert td3=(TripDetail.find_by_sql [" select * from trip_details where trip_id = ?", trip])[2]
    #someone elses trip
    get '/trips/'+trip.to_s+'/edit'
    assert :success
    assert_template 'trips/edit'

    assert_select "input#trip_name[value=?]", "My Trip"
    assert_select "input#trip_lengthmin", ""
    assert_select "input#trip_lengthmax", ""
    assert_select "div#trip_distance", "3.00 km"
    assert_select "div#trip_time", "3.5 DOC hours"
    assert_select "input#trip_published", false
    assert_select "textarea#trip_description", ""
    assert_select "div#links_section", false
    assert_select "div#comments_section", false
    assert_select  "span#editbutton", false
    assert_select  "span#save_button"
    assert_select  "span#cancel_button"
    assert_select  "span#delete_button"

    #items list
    assert_select 'div#cutItem'+td1.id.to_s
    assert_select 'div#cutItem'+td1.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td1.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td1.id.to_s+'[style=?]', /.*display:none.*/
    #reverses title and from/to
    assert_select "div#route_title1", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t1", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route1"
    #route2
    assert_select 'div#cutItem'+td2.id.to_s
    assert_select 'div#cutItem'+td2.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#route_title2", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route2"
    #route2
    assert_select 'div#cutItem'+td3.id.to_s
    assert_select 'div#cutItem'+td3.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#place_title3", @testplace.name+" (DOC Hut)"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at start
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"+td1.id.to_s 
    assert :success 
    assert_template 'trips/_show'

    assert_select "div#route_title1", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t1", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route1"
    #route2
    assert_select "div#route_title2", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t2", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route2"
    #route2
    assert_select "div#place_title3", @testplace.name+" (DOC Hut)"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at end
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"
    assert :success
    assert_template 'trips/_show'

    assert_select "div#route_title1", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t1", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route1"
    #
    assert_select "div#place_title2", @testplace.name+" (DOC Hut)"
    assert_select "div#place2"
    #route2
    assert_select "div#route_title3", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t3", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route3"

    assert_select "div#route4", false
    assert_select "div#place4", false

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td1.id.to_s, commit: "delete"
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @testplace.name+" (DOC Hut)"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false


  #reverse route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+td2.id.to_s
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @testplace.name+" (DOC Hut)"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @testroute2.endplace.name+' to '+@testroute2.startplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.endplace.name+' to '+@testroute2.startplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false

  #save trip
    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3000}, commit: "Save"

    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "(draft) Trip: changed name"
    assert_select "div#trip_length", "Length: from 9999999.0 up to 99999999.0 days"
    assert_select "div#trip_description", "a"*3000

  #delete trip
    oldcnt=Trip.count
    lasttrip=Trip.last.id

    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3000}, commit: "Delete"

    assert :success
    assert_template 'trips/show'
  
    #trip gone 
    assert_not Trip.find_by_id(trip)

    #new trip shown
    assert_select  "div.alert", "Trip deleted"
    assert_select "span#page_title", "(draft) Trip: My Trip"
    assert_select "div#trip_length", false
    assert_select "div#trip_description", ""

    #new trip created and is mine
    @ourguest.reload
    newtrip=@ourguest.currenttrip
    assert_equal newtrip.id, Trip.last.id
    assert_not_equal lasttrip, Trip.last.id
    assert_equal Trip.count, oldcnt
 
end

test "edit our trip as user" do
  trip=Trip.create(name: "test trip 1", createdBy_id: @testuser.id, lengthmin: 1, lengthmax: 3, published: true, description: "test trip 1 description").id
  td1=TripDetail.create(trip_id: trip, route_id: -@testroute.id, order: 1)
  td2=TripDetail.create(trip_id: trip, route_id: @testroute2.id, order: 2)
  td3=TripDetail.create(trip_id: trip, place_id: @testplace.id, order: 3)

   login_as(@testuser.name,"password")
   assert is_logged_in?
   @ouruser=User.find_by_id(session[:user_id])
 

    #someone elses trip
    get '/trips/'+trip.to_s+'/edit'
    assert :success
    assert_template 'trips/edit'

    assert_select "input#trip_name[value=?]", "test trip 1"
    assert_select "input#trip_lengthmin[value=?]", "1"
    assert_select "input#trip_lengthmax[value=?]", "3"
    assert_select "div#trip_distance", "3.00 km"
    assert_select "div#trip_time", "3.5 DOC hours"
    assert_select "input#trip_published", ""
    assert_select "textarea#trip_description", "test trip 1 description"
    assert_select "div#links_section", false
    assert_select "div#comments_section", false
    assert_select  "span#editbutton", false
    assert_select  "span#save_button"
    assert_select  "span#cancel_button"
    assert_select  "span#delete_button"

    #items list
    assert_select 'div#cutItem'+td1.id.to_s
    assert_select 'div#cutItem'+td1.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td1.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td1.id.to_s+'[style=?]', /.*display:none.*/
    #reverses title and from/to
    assert_select "div#route_title1", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t1", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route1"
    #route2
    assert_select 'div#cutItem'+td2.id.to_s
    assert_select 'div#cutItem'+td2.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#route_title2", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route2"
    #route2
    assert_select 'div#cutItem'+td3.id.to_s
    assert_select 'div#cutItem'+td3.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#place_title3", @testplace.name+" (DOC Hut)"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at start
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"+td1.id.to_s 
    assert :success 
    assert_template 'trips/_show'

    assert_select "div#route_title1", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t1", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route1"
    #route2
    assert_select "div#route_title2", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t2", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route2"
    #route2
    assert_select "div#place_title3", @testplace.name+" (DOC Hut)"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at end
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"
    assert :success
    assert_template 'trips/_show'

    assert_select "div#route_title1", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t1", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route1"
    #
    assert_select "div#place_title2", @testplace.name+" (DOC Hut)"
    assert_select "div#place2"
    #route2
    assert_select "div#route_title3", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t3", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route3"

    assert_select "div#route4", false
    assert_select "div#place4", false

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td1.id.to_s, commit: "delete"
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @testplace.name+" (DOC Hut)"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false


  #reverse route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+td2.id.to_s
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @testplace.name+" (DOC Hut)"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @testroute2.endplace.name+' to '+@testroute2.startplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.endplace.name+' to '+@testroute2.startplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false

  #save trip
    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3000}, commit: "Save"

    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "(draft) Trip: changed name"
    assert_select "div#trip_length", "Length: from 9999999.0 up to 99999999.0 days"
    assert_select "div#trip_description", "a"*3000

  #delete trip
    oldcnt=Trip.count
    lasttrip=Trip.last.id

    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3000}, commit: "Delete"

    assert :success
    assert_template 'trips/index'

    #trip gone 
    assert_not Trip.find_by_id(trip)

    #new trip shown
    assert_select  "div.alert", "Trip deleted"

    #new trip created and is mine
    @ouruser.reload
    newtrip=@ouruser.currenttrip
    assert_equal Trip.count, oldcnt-1

end
test "edit anothers trip as root" do
  trip=Trip.create(name: "test trip 1", createdBy_id: @testuser.id, lengthmin: 1, lengthmax: 3, published: true, description: "test trip 1 description").id
  td1=TripDetail.create(trip_id: trip, route_id: -@testroute.id, order: 1)
  td2=TripDetail.create(trip_id: trip, route_id: @testroute2.id, order: 2)
  td3=TripDetail.create(trip_id: trip, place_id: @testplace.id, order: 3)

   login_as(@testuser3.name,"password")
   assert is_logged_in?
   @ouruser=User.find_by_id(session[:user_id])
 

    #someone elses trip
    get '/trips/'+trip.to_s+'/edit'
    assert :success
    assert_template 'trips/edit'

    assert_select "input#trip_name[value=?]", "test trip 1"
    assert_select "input#trip_lengthmin[value=?]", "1"
    assert_select "input#trip_lengthmax[value=?]", "3"
    assert_select "div#trip_distance", "3.00 km"
    assert_select "div#trip_time", "3.5 DOC hours"
    assert_select "input#trip_published", ""
    assert_select "textarea#trip_description", "test trip 1 description"
    assert_select "div#links_section", false
    assert_select "div#comments_section", false
    assert_select  "span#editbutton", false
    assert_select  "span#save_button"
    assert_select  "span#cancel_button"
    assert_select  "span#delete_button"

    #items list
    assert_select 'div#cutItem'+td1.id.to_s
    assert_select 'div#cutItem'+td1.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td1.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td1.id.to_s+'[style=?]', /.*display:none.*/
    #reverses title and from/to
    assert_select "div#route_title1", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t1", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route1"
    #route2
    assert_select 'div#cutItem'+td2.id.to_s
    assert_select 'div#cutItem'+td2.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#route_title2", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route2"
    #route2
    assert_select 'div#cutItem'+td3.id.to_s
    assert_select 'div#cutItem'+td3.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#place_title3", @testplace.name+" (DOC Hut)"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at start
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"+td1.id.to_s 
    assert :success 
    assert_template 'trips/_show'

    assert_select "div#route_title1", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t1", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route1"
    #route2
    assert_select "div#route_title2", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t2", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route2"
    #route2
    assert_select "div#place_title3", @testplace.name+" (DOC Hut)"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at end
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"
    assert :success
    assert_template 'trips/_show'

    assert_select "div#route_title1", @testroute.endplace.name+' to '+@testroute.startplace.name+' via '+@testroute.via
    assert_select "div#fw_t1", 'From '+@testroute.endplace.name+' to '+@testroute.startplace.name
    assert_select "div#route1"
    #
    assert_select "div#place_title2", @testplace.name+" (DOC Hut)"
    assert_select "div#place2"
    #route2
    assert_select "div#route_title3", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t3", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route3"

    assert_select "div#route4", false
    assert_select "div#place4", false

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td1.id.to_s, commit: "delete"
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @testplace.name+" (DOC Hut)"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @testroute2.startplace.name+' to '+@testroute2.endplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.startplace.name+' to '+@testroute2.endplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false


  #reverse route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+td2.id.to_s
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @testplace.name+" (DOC Hut)"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @testroute2.endplace.name+' to '+@testroute2.startplace.name+' via '+@testroute2.via
    assert_select "div#fw_t2", 'From '+@testroute2.endplace.name+' to '+@testroute2.startplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false

  #save trip
    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3000}, commit: "Save"

    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "(draft) Trip: changed name"
    assert_select "div#trip_length", "Length: from 9999999.0 up to 99999999.0 days"
    assert_select "div#trip_description", "a"*3000

  #delete trip
    oldcnt=Trip.count
    lasttrip=Trip.last.id

    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3000}, commit: "Delete"

    assert :success
    assert_template 'trips/index'

    #trip gone 
    assert_not Trip.find_by_id(trip)

    #new trip shown
    assert_select  "div.alert", "Trip deleted"

    #new trip created and is mine
    @ouruser.reload
    newtrip=@ouruser.currenttrip
    assert_equal Trip.count, oldcnt-1

end

test "stranger cannot edit trip" do

    #someone elses trip
    get '/trips/'+@testtrip1.id.to_s+'/edit'
    assert_template 'trips/show' 
    assert_select "input#trip_name", false
    trip=@testtrip1.id
    t=@testtrip1
#paste at end
    i0=t.trip_details[0].order
    i1=t.trip_details[1].order
    i2=t.trip_details[2].order
    i3=t.trip_details[3].order
    
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: t.trip_details[3].id.to_s, commit: "paste"
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    #order unchanged
    assert_equal t.trip_details[0].order, i0
    assert_equal t.trip_details[1].order, i1
    assert_equal t.trip_details[2].order, i2
    assert_equal t.trip_details[3].order, i3

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: t.trip_details[3].id.to_s, commit: "delete"
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    assert_equal t.trip_details.count, 4

  #reverse route
    rid=t.trip_details[1].route_id
    assert_operator rid.abs, :>, 0

    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+t.trip_details[1].id.to_s
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    #route_id unchanegd
    assert_equal rid, t.trip_details[1].route_id

    #cannot save
    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Save"

    assert_template 'trips/show'

    @testtrip1.reload
    assert_equal @testtrip1.name, "test trip 1"
    assert_equal @testtrip1.lengthmin, 1
    assert_equal @testtrip1.lengthmax, 3
    assert_equal @testtrip1.description, "test trip 1 description"


    #cannot delete
    oldcnt=Trip.count

    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Delete"

    assert_template 'trips/show'

    #trip not deleted
    assert Trip.find_by_id(trip)
    assert_equal Trip.count, oldcnt
end


  #CAnnot edit others (guest) - cannot view edit form, cannot post
test "cannot edit others trip as guest" do
    add_place_to_trip(@testplace)
    assert is_guest?

    #someone elses trip
    get '/trips/'+@testtrip1.id.to_s+'/edit'
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    trip=@testtrip1.id
    t=@testtrip1
#paste at end
    i0=t.trip_details[0].order
    i1=t.trip_details[1].order
    i2=t.trip_details[2].order
    i3=t.trip_details[3].order

    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: t.trip_details[3].id.to_s, commit: "paste"
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    #order unchanged
    assert_equal t.trip_details[0].order, i0
    assert_equal t.trip_details[1].order, i1
    assert_equal t.trip_details[2].order, i2
    assert_equal t.trip_details[3].order, i3

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: t.trip_details[3].id.to_s, commit: "delete"
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    assert_equal t.trip_details.count, 4

  #reverse route
    rid=t.trip_details[1].route_id
    assert_operator rid.abs, :>, 0

    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+t.trip_details[1].id.to_s
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    #route_id unchanegd
    assert_equal rid, t.trip_details[1].route_id

    #cannot save
    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Save"

    assert_template 'trips/show'

    @testtrip1.reload
    assert_equal @testtrip1.name, "test trip 1"
    assert_equal @testtrip1.lengthmin, 1
    assert_equal @testtrip1.lengthmax, 3
    assert_equal @testtrip1.description, "test trip 1 description"


    #cannot delete
    oldcnt=Trip.count

    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Delete"

    assert_template 'trips/show'

    #trip not deleted
    assert Trip.find_by_id(trip)
    assert_equal Trip.count, oldcnt


end

  #CAnnot edit others (user) - cannot view edit form, cannot post
test "cannot edit anothers trip as user" do
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    #someone elses trip
    get '/trips/'+@testtrip1.id.to_s+'/edit'
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    trip=@testtrip1.id
    t=@testtrip1
#paste at end
    i0=t.trip_details[0].order
    i1=t.trip_details[1].order
    i2=t.trip_details[2].order
    i3=t.trip_details[3].order

    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: t.trip_details[3].id.to_s, commit: "paste"
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    #order unchanged
    assert_equal t.trip_details[0].order, i0
    assert_equal t.trip_details[1].order, i1
    assert_equal t.trip_details[2].order, i2
    assert_equal t.trip_details[3].order, i3

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: t.trip_details[3].id.to_s, commit: "delete"
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    assert_equal t.trip_details.count, 4

  #reverse route
    rid=t.trip_details[1].route_id
    assert_operator rid.abs, :>, 0

    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+t.trip_details[1].id.to_s
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    t.reload
    #route_id unchanegd
    assert_equal rid, t.trip_details[1].route_id

    #cannot save
    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Save"

    assert_template 'trips/show'

    @testtrip1.reload
    assert_equal @testtrip1.name, "test trip 1"
    assert_equal @testtrip1.lengthmin, 1
    assert_equal @testtrip1.lengthmax, 3
    assert_equal @testtrip1.description, "test trip 1 description"


    #cannot delete
    oldcnt=Trip.count

    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Delete"

    assert_template 'trips/show'

    #trip not deleted
    assert Trip.find_by_id(trip)
    assert_equal Trip.count, oldcnt

end

#####################################

test "null and invalid values in trip" do
    login_as(@testuser.name,"password")
    assert is_logged_in?

    #our trip
    get '/trips/'+@testtrip1.id.to_s+'/edit'
    trip=@testtrip1.id
    t=@testtrip1

  #leading / trialing spaces in name
    patch '/trips/'+trip.to_s, trip: { name: " test ", lengthmin: "9999999",lengthmax: "99999999", description: "a"*3}, commit: "Save"

    assert :success
    assert_template 'trips/show'
    @testtrip1.reload
    assert_equal @testtrip1.name, "test"
    assert_select "span#page_title", "(draft) Trip: test"
    assert_select "div#trip_length", "Length: from 9999999.0 up to 99999999.0 days"
    assert_select "div#trip_description", "aaa"


  #zero length name
    patch '/trips/'+trip.to_s, trip: { name: "  ", lengthmin: "8999999",lengthmax: "89999999", description: "b"*3}, commit: "Save"

    assert_template 'trips/edit'
    @testtrip1.reload
    assert_equal "test", @testtrip1.name
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name can&#39;t be blank"
    assert_select "input#trip_name[value=?]", ""
    assert_select "input#trip_lengthmin[value=?]", "8999999.0"
    assert_select "input#trip_lengthmax[value=?]", "89999999.0"
    assert_select "textarea#trip_description", "bbb"


  #null name
    patch '/trips/'+trip.to_s, trip: { lengthmin: 8999999,lengthmax: 89999999, description: "b"*3}, commit: "Save"

    assert_template 'trips/edit'
    @testtrip1.reload
    assert_equal @testtrip1.name, "test"
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name can&#39;t be blank"
    assert_select "input#trip_name[value=?]", ""
    assert_select "input#trip_lengthmin[value=?]", "8999999.0"
    assert_select "input#trip_lengthmax[value=?]", "89999999.0"
    assert_select "textarea#trip_description", "bbb"

  #null length, description - allowed
    patch '/trips/'+trip.to_s, trip: { name: " test "}, commit: "Save"

    assert :success
    assert_template 'trips/show'
    @testtrip1.reload
    assert_equal @testtrip1.name, "test"
    assert_equal @testtrip1.lengthmin, 0
    assert_equal @testtrip1.lengthmax, 0
    assert_equal @testtrip1.description, nil
    assert_select "span#page_title", "(draft) Trip: test"
    assert_select "div#trip_length",false
    assert_select "div#trip_description", ""


  #blank length, description
    patch '/trips/'+trip.to_s, trip: { name: "test2", lengthmin: "",lengthmax: "", description: ""}, commit: "Save"

    assert :success
    assert_template 'trips/show'
    @testtrip1.reload
    assert_equal @testtrip1.name, "test2"
    assert_equal @testtrip1.lengthmin, 0
    assert_equal @testtrip1.lengthmax, 0
    assert_equal @testtrip1.description, ""
    assert_select "span#page_title", "(draft) Trip: test2"
    assert_select "div#trip_length",false
    assert_select "div#trip_description", ""

end


  #non existant trip
test "edit trip with non-existant id" do
    login_as(@testuser.name,"password")
    assert is_logged_in?

    #edit
    get '/trips/999/edit'
    follow_redirect!
    assert_template 'trips/index'
    assert_select "input#trip_name", false

    #paste at end
    oldorder=@td1a.order
    post '/trips/move',  pasteAfter: nil, id: 999, cutFrom: @td1a.id.to_s, commit: "paste"
    follow_redirect!
    assert_template 'trips/index'
    assert_select "input#trip_name", false

    #order unchanged
    @td1a.reload
    assert_equal @td1a.order, oldorder

    #delete route
    post '/trips/move',  pasteAfter: nil, id: 999, cutFrom: @td1a.id.to_s, commit: "delete"
    follow_redirect!
    assert_template 'trips/index'
    assert_select "input#trip_name", false
    #td exists, order unchanged
    @td1a.reload
    assert_equal @td1a.order, oldorder

    #reverse route
    rid=@td1b.route_id
    assert_operator rid.abs, :>, 0

    post '/trips/move',  pasteAfter: nil, id: 999, cutFrom: nil, commit: "reverse"+@td1b.id.to_s
    follow_redirect!
    assert_template 'trips/index'
    assert_select "input#trip_name", false
    #route_id unchanegd
    @td1b.reload
    assert_equal @td1b.route_id, rid

    #cannot save
    patch '/trips/999', trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Save"
    follow_redirect!
    assert_template 'trips/index'

    #cannot delete
    oldcnt=Trip.count
    patch '/trips/999', trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Delete"
    follow_redirect!
    assert_template 'trips/index'

    #trip not deleted
    assert_equal Trip.count, oldcnt

end

end

