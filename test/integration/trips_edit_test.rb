require 'test_helper'

class TripsEditTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "edit our trip as guest" do
   add_route_to_trip_rv(@route)
   add_route_to_trip_fw(@route2)
   add_place_to_trip(@place)
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
    assert_select "div#route_title1", @route.endplace.name+' to '+@route.startplace.name+' via '+@route.via
    assert_select "div#fw_t1", 'From '+@route.endplace.name+' to '+@route.startplace.name
    assert_select "div#route1"
    #route2
    assert_select 'div#cutItem'+td2.id.to_s
    assert_select 'div#cutItem'+td2.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#route_title2", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t2", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route2"
    #route2
    assert_select 'div#cutItem'+td3.id.to_s
    assert_select 'div#cutItem'+td3.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#place_title3", @place.name+" ("+@place.place_type+")"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at start
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"+td1.id.to_s 
    assert :success 
    assert_template 'trips/_show'

    assert_select "div#route_title1", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t1", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route1"
    #route2
    assert_select "div#route_title2", @route.endplace.name+' to '+@route.startplace.name+' via '+@route.via
    assert_select "div#fw_t2", 'From '+@route.endplace.name+' to '+@route.startplace.name
    assert_select "div#route2"
    #route2
    assert_select "div#place_title3", @place.name+" ("+@place.place_type+")"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at end
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"
    assert :success
    assert_template 'trips/_show'

    assert_select "div#route_title1", @route.endplace.name+' to '+@route.startplace.name+' via '+@route.via
    assert_select "div#fw_t1", 'From '+@route.endplace.name+' to '+@route.startplace.name
    assert_select "div#route1"
    #
    assert_select "div#place_title2", @place.name+" ("+@place.place_type+")"
    assert_select "div#place2"
    #route2
    assert_select "div#route_title3", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t3", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route3"

    assert_select "div#route4", false
    assert_select "div#place4", false

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td1.id.to_s, commit: "delete"
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @place.name+" ("+@place.place_type+")"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t2", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false


  #reverse route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+td2.id.to_s
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @place.name+" ("+@place.place_type+")"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @route2.endplace.name+' to '+@route2.startplace.name+' via '+@route2.via
    assert_select "div#fw_t2", 'From '+@route2.endplace.name+' to '+@route2.startplace.name
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
  trip=Trip.create(name: "test trip 1", createdBy_id: @user.id, lengthmin: 1, lengthmax: 3, published: true, description: "test trip 1 description").id
  td1=TripDetail.create(trip_id: trip, route_id: -@route.id, order: 1)
  td2=TripDetail.create(trip_id: trip, route_id: @route2.id, order: 2)
  td3=TripDetail.create(trip_id: trip, place_id: @place.id, order: 3)

   login_as(@user.name,"password")
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
    assert_select "div#route_title1", @route.endplace.name+' to '+@route.startplace.name+' via '+@route.via
    assert_select "div#fw_t1", 'From '+@route.endplace.name+' to '+@route.startplace.name
    assert_select "div#route1"
    #route2
    assert_select 'div#cutItem'+td2.id.to_s
    assert_select 'div#cutItem'+td2.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td2.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#route_title2", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t2", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route2"
    #route2
    assert_select 'div#cutItem'+td3.id.to_s
    assert_select 'div#cutItem'+td3.id.to_s+'[style=?]', /.*display:none.*/, false
    assert_select 'div#pasteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    assert_select 'div#deleteItem'+td3.id.to_s+'[style=?]', /.*display:none.*/
    #
    assert_select "div#place_title3", @place.name+" ("+@place.place_type+")"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at start
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"+td1.id.to_s 
    assert :success 
    assert_template 'trips/_show'

    assert_select "div#route_title1", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t1", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route1"
    #route2
    assert_select "div#route_title2", @route.endplace.name+' to '+@route.startplace.name+' via '+@route.via
    assert_select "div#fw_t2", 'From '+@route.endplace.name+' to '+@route.startplace.name
    assert_select "div#route2"
    #route2
    assert_select "div#place_title3", @place.name+" ("+@place.place_type+")"
    assert_select "div#place3"

    assert_select "div#route4", false
    assert_select "div#place4", false

#paste at end
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td2.id.to_s, commit: "paste"
    assert :success
    assert_template 'trips/_show'

    assert_select "div#route_title1", @route.endplace.name+' to '+@route.startplace.name+' via '+@route.via
    assert_select "div#fw_t1", 'From '+@route.endplace.name+' to '+@route.startplace.name
    assert_select "div#route1"
    #
    assert_select "div#place_title2", @place.name+" ("+@place.place_type+")"
    assert_select "div#place2"
    #route2
    assert_select "div#route_title3", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t3", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route3"

    assert_select "div#route4", false
    assert_select "div#place4", false

 #delete route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: td1.id.to_s, commit: "delete"
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @place.name+" ("+@place.place_type+")"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @route2.startplace.name+' to '+@route2.endplace.name+' via '+@route2.via
    assert_select "div#fw_t2", 'From '+@route2.startplace.name+' to '+@route2.endplace.name
    assert_select "div#route2"

    assert_select "div#route3", false
    assert_select "div#place3", false


  #reverse route
    post '/trips/move',  pasteAfter: nil, id:  trip.to_s,cutFrom: nil, commit: "reverse"+td2.id.to_s
    assert :success
    assert_template 'trips/_show'

    #
    assert_select "div#place_title1", @place.name+" ("+@place.place_type+")"
    assert_select "div#place1"
    #route2
    assert_select "div#route_title2", @route2.endplace.name+' to '+@route2.startplace.name+' via '+@route2.via
    assert_select "div#fw_t2", 'From '+@route2.endplace.name+' to '+@route2.startplace.name
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
    get '/trips/'+@trip1.id.to_s+'/edit'
    assert_template 'trips/show' 
    assert_select "input#trip_name", false
    trip=@trip1.id
    t=@trip1
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

    @trip1.reload
    assert_equal @trip1.name, "test trip 1"
    assert_equal @trip1.lengthmin, 1
    assert_equal @trip1.lengthmax, 3
    assert_equal @trip1.description, "test trip 1 description"


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
    add_place_to_trip(@place)
    assert is_guest?

    #someone elses trip
    get '/trips/'+@trip1.id.to_s+'/edit'
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    trip=@trip1.id
    t=@trip1
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

    @trip1.reload
    assert_equal @trip1.name, "test trip 1"
    assert_equal @trip1.lengthmin, 1
    assert_equal @trip1.lengthmax, 3
    assert_equal @trip1.description, "test trip 1 description"


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
    login_as(@user2.name,"password")
    assert is_logged_in?

    #someone elses trip
    get '/trips/'+@trip1.id.to_s+'/edit'
    assert_template 'trips/show'
    assert_select "input#trip_name", false
    trip=@trip1.id
    t=@trip1
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

    @trip1.reload
    assert_equal @trip1.name, "test trip 1"
    assert_equal @trip1.lengthmin, 1
    assert_equal @trip1.lengthmax, 3
    assert_equal @trip1.description, "test trip 1 description"


    #cannot delete
    oldcnt=Trip.count

    patch '/trips/'+trip.to_s, trip: { name: "changed name", lengthmin: 9999999,lengthmax: 99999999, description: "a"*3}, commit: "Delete"

    assert_template 'trips/show'

    #trip not deleted
    assert Trip.find_by_id(trip)
    assert_equal Trip.count, oldcnt

end

#####################################

  #Handling nulls

  #non existant trip

  #Can edit others (root)

  #missing mandatory fields (name)

  #download GPX
end

