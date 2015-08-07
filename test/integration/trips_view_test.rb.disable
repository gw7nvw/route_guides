require 'test_helper'

class TripsViewTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "view trip as stranger" do
    #navigate to my trip

    get '/trips/'+@testtrip1.id.to_s
    assert :success
    assert_template 'trips/show'
    
    assert_select "span#page_title", "Trip: test trip 1"
    assert_select "div#trip_length", "Length: from 1.0 up to 3.0 days"
    assert_select "span#agg_dist", "Distance: 3.0 km"
    assert_select "span#agg_time", "(3.5 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 100m to 400m.  Gain: 200m.  Loss: 0m"
    assert_select "span#agg_grad", ".  Gradient: 4 deg"
    assert_select "span#maxroutetype", {:count =>1, :text=> /.*Surfaced walkway.*/}
    assert_select "span#maxterrain", /.*Easy-moderate terrain.*/
    assert_select "span#maxgradient", /.*Gentle.*/
    assert_select "span#maxalpines", /.*Alpine weather.*/
    assert_select "span#maxalpinew", /.*Snow\/ice underfoot.*/
    assert_select "span#maxriver", /.*Streams.*/
    assert_select "div#trip_description", "test trip 1 description"

    assert_select "div#place_details>div.erow>div.sectiontitle25", {:count =>1, :text=> @testplace.name+" (DOC Hut)"}
    assert_select "div#place1"
    assert_select "div#route2"
    assert_select "div#place3"
    assert_select "div#route4"
    assert_select "div#place5", false

    assert_select "div#links_section"

    assert_select "div#comments_section"

    #download gpx enabled
    assert_select "a[href=?]", '/trips/'+@testtrip1.id.to_s+'.gpx'

    #edit disabled
    assert_select  "span#editbutton", false
end

test "view trips as guest" do
   add_route_to_trip_rv(@testroute)
   @ourguest=Guest.find_by_id(session[:guest_id])

   assert is_guest?
   trip=@ourguest.currenttrip_id

    #someone elses trip
    get '/trips/'+@testtrip1.id.to_s
    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "Trip: test trip 1"
    assert_select "div#trip_length", "Length: from 1.0 up to 3.0 days"
    assert_select "span#agg_dist", "Distance: 3.0 km"
    assert_select "span#agg_time", "(3.5 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 100m to 400m.  Gain: 200m.  Loss: 0m"
    assert_select "span#agg_grad", ".  Gradient: 4 deg"
    assert_select "div#trip_description", "test trip 1 description"
    assert_select "span#maxroutetype", /.*Surfaced walkway.*/
    assert_select "span#maxterrain", /.*Easy-moderate terrain.*/
    assert_select "span#maxgradient", /.*Gentle.*/
    assert_select "span#maxalpines", /.*Alpine weather.*/
    assert_select "span#maxalpinew", /.*Snow\/ice underfoot.*/
    assert_select "span#maxriver", /.*Streams.*/

    assert_select "div#place_details>div.erow>div.sectiontitle25", {:count =>1, :text=> @testplace.name+" (DOC Hut)"}
    assert_select "div#place1"
    assert_select "div#route2"
    assert_select "div#place3"
    assert_select "div#route4"
    assert_select "div#place5", false
    assert_select "div#links_section"
    assert_select "div#comments_section"
    assert_select "a[href=?]", '/trips/'+@testtrip1.id.to_s+'.gpx'
    assert_select  "span#editbutton", false

    #My Trip
    get '/trips/'+trip.to_s
    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "(draft) Trip: My Trip"
    assert_select "div#trip_length", false
    assert_select "span#agg_dist", "Distance: 1.0 km"
    assert_select "span#agg_time", "(3.0 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 300m to 400m.  Gain: 0m.  Loss: 100m"
    assert_select "span#agg_grad", ".  Gradient: 6 deg"
    assert_select "span#maxroutetype", /.*Road.*/
    assert_select "span#maxterrain", /.*Easy terrain.*/
    assert_select "span#maxgradient", /.*Flat.*/
    assert_select "span#maxalpines", ""
    assert_select "span#maxalpinew", ""
    assert_select "span#maxriver", ""
    assert_select "div#trip_description"

    assert_select "div#route1"
    assert_select "div#place2", false
    assert_select "div#route2", false
    assert_select "div#links_section"
    assert_select "div#comments_section"
    assert_select "a[href=?]", '/trips/'+trip.to_s+'.gpx'
    assert_select  "span#editbutton"

   
end


test "view trips as user" do
   login_as(@testuser2.name, "password")
   assert is_logged_in?

    #someone elses trip
    get '/trips/'+@testtrip1.id.to_s
    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "Trip: test trip 1"
    assert_select "div#trip_length", "Length: from 1.0 up to 3.0 days"
    assert_select "span#agg_dist", "Distance: 3.0 km"
    assert_select "span#agg_time", "(3.5 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 100m to 400m.  Gain: 200m.  Loss: 0m"
    assert_select "span#agg_grad", ".  Gradient: 4 deg"
    assert_select "span#maxroutetype", /.*Surfaced walkway.*/
    assert_select "span#maxterrain", /.*Easy-moderate terrain.*/
    assert_select "span#maxgradient", /.*Gentle.*/
    assert_select "span#maxalpines", /.*Alpine weather.*/
    assert_select "span#maxalpinew", /.*Snow\/ice underfoot.*/
    assert_select "span#maxriver", /.*Streams.*/
    assert_select "div#trip_description", "test trip 1 description"

    assert_select "div#place1"
    assert_select "div#route2"
    assert_select "div#place3"
    assert_select "div#route4"
    assert_select "div#place5", false
    assert_select "div#links_section"
    assert_select "div#comments_section"
    assert_select "a[href=?]", '/trips/'+@testtrip1.id.to_s+'.gpx'
       #no edit
    assert_select  "span#editbutton", false

    #My Trip
    get '/trips/'+@testtrip4.id.to_s
    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "Trip: test trip 4"
    assert_select "div#trip_length", "Length: from 2.0 up to 4.0 days"
    assert_select "span#agg_dist", "Distance: 1.0 km"
    assert_select "span#agg_time", "(3.0 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 300m to 400m.  Gain: 0m.  Loss: 100m"
    assert_select "span#agg_grad", ".  Gradient: 6 deg"
    assert_select "span#maxroutetype", /.*Road.*/
    assert_select "span#maxterrain", /.*Easy terrain.*/
    assert_select "span#maxgradient", /.*Flat.*/
    assert_select "span#maxalpines", ""
    assert_select "span#maxalpinew", ""
    assert_select "span#maxriver", ""
    assert_select "div#trip_description"

    assert_select "div#route1"
    assert_select "div#place2", false
    assert_select "div#route2", false
    assert_select "div#links_section"
    assert_select "div#comments_section"
    assert_select "a[href=?]", '/trips/'+@testtrip4.id.to_s+'.gpx'
       #edit allowed
    assert_select  "span#editbutton"
end
################################

# View a trip 

test "view trip with null stats" do
    #use route with null stats
    @td4a.route_id=@testroute3.id
    @td4a.save
    @testtrip4.published=false
    @testtrip4.save

    get '/trips/'+@testtrip4.id.to_s
    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "(draft) Trip: test trip 4"
    assert_select "div#trip_length", "Length: from 2.0 up to 4.0 days"
    assert_select "span#agg_dist", ""
    assert_select "span#agg_time", ""
    assert_select "span#agg_alt", ""
    assert_select "span#agg_grad", ""
    assert_select "span#maxroutetype", ""
    assert_select "span#maxterrain", ""
    assert_select "span#maxgradient", ""
    assert_select "span#maxalpines", ""
    assert_select "span#maxalpinew", ""
    assert_select "span#maxriver", ""
    assert_select "div#trip_description"

    assert_select "div#route1"
    assert_select "div#place2", false
    assert_select "div#route2", false
    assert_select "div#links_section"
    assert_select "div#comments_section"
    assert_select "a[href=?]", '/trips/'+@testtrip4.id.to_s+'.gpx'
       #edit allowed

end

test "view trips as root" do
   login_as(@testuser3.name, "password")
   assert is_logged_in?

    #someone elses trip
    get '/trips/'+@testtrip1.id.to_s
    assert :success
    assert_template 'trips/show'

    assert_select "span#page_title", "Trip: test trip 1"
    assert_select "div#trip_length", "Length: from 1.0 up to 3.0 days"
    assert_select "span#agg_dist", "Distance: 3.0 km"
    assert_select "span#agg_time", "(3.5 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 100m to 400m.  Gain: 200m.  Loss: 0m"
    assert_select "span#agg_grad", ".  Gradient: 4 deg"
    assert_select "span#maxroutetype", /.*Surfaced walkway.*/
    assert_select "span#maxterrain", /.*Easy-moderate terrain.*/
    assert_select "span#maxgradient", /.*Gentle.*/
    assert_select "span#maxalpines", /.*Alpine weather.*/
    assert_select "span#maxalpinew", /.*Snow\/ice underfoot.*/
    assert_select "span#maxriver", /.*Streams.*/
    assert_select "div#trip_description", "test trip 1 description"

    assert_select "div#place1"
    assert_select "div#route2"
    assert_select "div#place3"
    assert_select "div#route4"
    assert_select "div#place5", false
    assert_select "div#links_section"
    assert_select "div#comments_section"
    assert_select "a[href=?]", '/trips/'+@testtrip1.id.to_s+'.gpx'
       #can edit
    assert_select  "span#editbutton"


end

#view nonexistant trip
test "view nonexistant trip" do
    get '/trips/9999'
    follow_redirect!
    assert_template root_path
end

  #download GPX 2 routes with points and one empty route
test "download trip gpx" do
  trip=Trip.create(name: "test trip 1", createdBy_id: @testuser.id, lengthmin: 1, lengthmax: 3, published: true, description: "test trip 1 description").id
  td1=TripDetail.create(trip_id: trip, route_id: -@testroute.id, order: 1)
  td2=TripDetail.create(trip_id: trip, route_id: @testroute3.id, order: 2)
  td3=TripDetail.create(trip_id: trip, route_id: @testroute2.id, order: 2)
  td4=TripDetail.create(trip_id: trip, place_id: @testplace.id, order: 3)


    #our trip
    get '/trips/'+trip.to_s+'.gpx'

    reslat=[]
    reslon=[]

  #segment 1 - reversed
    reslat[0]='-49.0'
    reslon[0]='177.0'
    reslat[1]='-49.0'
    reslon[1]='175.0'
  #segment 2 - forward
    reslat[2]='-50.0'
    reslon[2]='176.0'
    reslat[3]='-50.0'
    reslon[3]='177.0'

    cnt=0
    tscnt=0
    #start of first to end of last
    assert_select "name", "testplacei4 to testplace"
    assert_select "trkseg", count:3  do |tts|
      tts.each do |tt|
        if tscnt==0 or tscnt==2 then
          assert_select tt, "trkpt", count:2  do |tps|
            tps.each do |tp|
              assert_select tp, 'trkpt[lat=?]',  reslat[cnt]
              assert_select tp, 'trkpt[lon=?]',  reslon[cnt]
             cnt+=1
            end
          end
        else assert_select tt, "trkpnt", false end
        tscnt+=1
      end
    end
 end

   #gpx with no routes
test "download trip gpx with no routes" do
  trip=Trip.create(name: "test trip 1", createdBy_id: @testuser.id, lengthmin: 1, lengthmax: 3, published: true, description: "test trip 1 description").id
  td4=TripDetail.create(trip_id: trip, place_id: @testplace.id, order: 1)


    #our trip
    get '/trips/'+trip.to_s+'.gpx'

    #start of first to end of last
    assert_select "trkseg", count:0

 end


#####################################

#Edit a trip
  #Fileds and values

  #Handling nulls

  #Cannot edit (not registered) - cannot view edit form, cannot post

  #CAnnot edit others (guest) - cannot view edit form, cannot post

  #CAnnot edit others (user) - cannot view edit form, cannot post

  #Can edit own (guest)

  #Can edit own (user)

  #Can edit others (root)

  #missing mandatory fields (name)

#Reordering a trip    
  #Cut 1st, paste last
  #Cut last, paste middle
  #Cut middle, paste first
  #Cut middle, delete
  #Cut last, delete
  #Cut 1st, delete
  #Delete all
  #Guest can reorder own
  #USer can reorder own
  #Root can reorder others
  #user cannot reorder others (post)
  #guest cannot reorder others (post)
  #unregistered cannot reorder any (post)

#deleting a trip
  #Guest can delete own
  #USer can delete own
  #Root can delete others
  #user cannot delete others (post)
  #guest cannot delete others (post)
  #unregistered cannot delete any (post)

#download GPX
end

