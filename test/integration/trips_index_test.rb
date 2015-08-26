require 'test_helper'

class TripsIndexTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end


# trip indexa
test "view trip index as stranger" do
  get '/trips'
  assert_response :success
  assert_select "div#page_title", "Trips"
   assert_select "span#triprow1", "test trip 1 by Example user1"
   assert_select "div#tripstats1", "1.0 to 3.0 days | 3.00 km | 3.5 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow2", "test trip 3 by Example user1"
   assert_select "div#tripstats2", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow3", "test trip 4 by Example user2"
   assert_select "div#tripstats3", "2.0 to 4.0 days | 1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"
   #no more rows
   assert_select "span#triprow4", false
   #no ticks
   assert_select "input#selectCurrent", false
   #no delete
   assert_select "input#Delete", false
   #no add
   assert_select "a#addbutton", false
end

test "view trip index as guest" do
   add_route_to_trip_fw(@testroute)
   @ourguest=Guest.find_by_id(session[:guest_id]) 

   assert is_guest?
   trip=@ourguest.currenttrip_id

   get '/trips'
  assert_response :success
  assert_select "div#page_title", "Trips"
   assert_select "span#triprow1", "(draft) My Trip"
   assert_select "div#tripstats1", "1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "div#selectedrow1"
   assert_select "span#triprow2", "test trip 1 by Example user1"
   assert_select "div#tripstats2", "1.0 to 3.0 days | 3.00 km | 3.5 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow3", "test trip 3 by Example user1"
   assert_select "div#tripstats3", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow4", "test trip 4 by Example user2"
   assert_select "div#tripstats4", "2.0 to 4.0 days | 1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"

   #no more rows
   assert_select "span#triprow5", false
   #no ticks
   assert_select "input#selectCurrent", false
   #no delete
   assert_select "input#Delete", false
   #no add
   assert_select "a#addbutton", false
end


 #user - published plus own
   #own tick and green
test "view trip index as user" do
   login_as(@testuser.name, "password")
   assert is_logged_in?
   @testuser.currenttrip=@testtrip3
   @testuser.save

   get '/trips'
   assert_response :success
   assert_select "div#page_title", "Trips"
   assert_select "span#triprow1", "test trip 1 by Example user1"
   assert_select "div#tripstats1", "1.0 to 3.0 days | 3.00 km | 3.5 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow2", "(draft) test trip 2 by Example user1"
   assert_select "div#tripstats2", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow3", "test trip 3 by Example user1"
   assert_select "div#tripstats3", "(updated "+Time.now().strftime("%F")+")"
   assert_select "div#selectedrow3"
   assert_select "span#triprow4", "test trip 4 by Example user2"
   assert_select "div#tripstats4", "2.0 to 4.0 days | 1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"

   #no more rows
   assert_select "span#triprow5", false
   #ticks for my 3 entries, not for other users'
   assert_select "input#selectCurrent", 3
   #no delete
   assert_select "input#Delete", false
   #no add
   assert_select "a#addbutton", false

   #different user
    delete signout_path
    follow_redirect!
    assert_not is_logged_in?

   login_as(@testuser2.name, "password")
   assert is_logged_in?

  get '/trips'
   assert_response :success
   assert_select "div#page_title", "Trips"
   assert_select "span#triprow1", "test trip 1 by Example user1"
   assert_select "div#tripstats1", "1.0 to 3.0 days | 3.00 km | 3.5 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow2", "test trip 3 by Example user1"
   assert_select "div#tripstats2", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow3", "test trip 4 by Example user2"
   assert_select "div#tripstats3", "2.0 to 4.0 days | 1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"

   #no more rows
   assert_select "span#triprow4", false
   #ticks for my 1 entries, not for other users'
   assert_select "input#selectCurrent", 1
   #no delete
   assert_select "input#Delete", false
   #no add
   assert_select "a#addbutton", false
end

 #root - all
   #own tick and green
test "view trip index as root" do
   #create a guest trip
   add_route_to_trip_fw(@testroute)
   @ourguest=Guest.find_by_id(session[:guest_id])

   assert is_guest?
   trip=@ourguest.currenttrip_id

   #now login as root
   login_as(@testuser3.name, "password")
   assert is_logged_in?

   get '/trips'
   assert_response :success
   assert_select "div#page_title", "Trips"
   # root sees all deafts
   assert_select "span#triprow1", "(draft) My Trip"
   assert_select "div#tripstats1", "1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow2", "test trip 1 by Example user1"
   assert_select "div#tripstats2", "1.0 to 3.0 days | 3.00 km | 3.5 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow3", "(draft) test trip 2 by Example user1"
   assert_select "div#tripstats3", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow4", "test trip 3 by Example user1"
   assert_select "div#tripstats4", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow5", "test trip 4 by Example user2"
   assert_select "div#tripstats5", "2.0 to 4.0 days | 1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"

   #no more rows
   assert_select "span#triprow6", false
   #ticks for all entries
   assert_select "input#selectCurrent", 5
   #no delete
   assert_select "input#Delete", false
   #no add
   assert_select "a#addbutton", false
end

#my trips (wishlist) stranger
test "view My Trips as stranger" do

   get '/wishlist'
   assert_response :success
   assert_select "div#page_title", "My Trips"
   #no more rows
   assert_select "span#triprow1", false
   #no ticks
   assert_select "input#selectCurrent", false
   # delete
   assert_select "input#Delete", false
   # add
   assert_select "a#addbutton", false
end
#my trips (wishlist) guest
test "view My Trips as guest" do
   add_place_to_trip(@testplace)
   assert is_guest?

   get '/wishlist'
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select "span#triprow1", "(draft) My Trip"
   assert_select "div#tripstats1", "(updated "+Time.now().strftime("%F")+")"
   #no more rows
   assert_select "span#triprow2", false
   #no ticks
   assert_select "input#selectCurrent", false
   # delete
   assert_select "input#Delete", 1
   # add
   assert_select "a#addbutton", false
end

#my trips (wishlist) suer
test "view My Trips as user" do
   login_as(@testuser.name, "password")
   assert is_logged_in?
   @testuser.currenttrip=@testtrip3
   @testuser.save

   get '/wishlist'
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select "span#triprow1", "(draft) test trip 2 by Example user1"
   assert_select "div#tripstats1", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow2", "test trip 1 by Example user1"
   assert_select "div#tripstats2", "1.0 to 3.0 days | 3.00 km | 3.5 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow3", "test trip 3 by Example user1"
   assert_select "div#tripstats3", "(updated "+Time.now().strftime("%F")+")"
   assert_select "div#selectedrow3"

   #no more rows
   assert_select "span#triprow4", false
   #ticks for my 3 entries, not for other users'
   assert_select "input#selectCurrent", 3
   # delete
   assert_select "input#Delete", 3
   # add
   assert_select "a#addbutton[alt=?]", "Add"
end

#selelct a trip (user, wishlist)
test "select different current trip from wishlist" do
   login_as(@testuser.name, "password")
   assert is_logged_in?
   @testuser.currenttrip=@testtrip3
   @testuser.save

   get '/wishlist'
   assert_response :success
   
   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'wishlist',
                         commit: 'Select as current' }
   assert_response :success
   @testuser.reload
   assert @testuser.currenttrip_id, @testtrip1.id

   #redisplays wishlist with new trip selected
   assert_select "div#page_title", "My Trips"
   assert_select "span#triprow1", "(draft) test trip 2 by Example user1"
   assert_select "span#triprow2", "test trip 1 by Example user1"
   assert_select "span#triprow3", "test trip 3 by Example user1"
   assert_select "div#selectedrow2"

   assert_select "span#triprow4", false
   assert_select "input#selectCurrent", 3
   assert_select "input#Delete", 3
   assert_select "a#addbutton[alt=?]", "Add"
end
#select a trip (user, index)
test "select different current trip from index" do
   login_as(@testuser.name, "password")
   assert is_logged_in?
   @testuser.currenttrip=@testtrip3
   @testuser.save

   get '/trips'
   assert_response :success
   
   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'index',
                         commit: 'Select as current' }
   assert_response :success
   @testuser.reload
   assert @testuser.currenttrip_id, @testtrip1.id

   #ticks for my 3 entries, not for other users'

   #redisplays index with new trip selected
   assert_select "div#page_title", "Trips"
   assert_select "span#triprow1", "test trip 1 by Example user1"
   assert_select "span#triprow2", "(draft) test trip 2 by Example user1"
   assert_select "span#triprow3", "test trip 3 by Example user1"
   assert_select "span#triprow4", "test trip 4 by Example user2"
   assert_select "div#selectedrow1"
   assert_select "span#triprow5", false
   assert_select "input#selectCurrent", 3
   assert_select "input#Delete", false
   assert_select "a#addbutton", false
end

#seelct a trip (root) of another user
test "select different current trip from index as root" do
   login_as(@testuser3.name, "password")
   assert is_logged_in?
   @testuser3.currenttrip=@testtrip3
   @testuser3.save

   get '/trips'
   assert_response :success

   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'index',
                         commit: 'Select as current' }
   assert_response :success
   @testuser3.reload
   assert @testuser3.currenttrip_id, @testtrip1.id

   #ticks for my 3 entries, not for other users'

   #redisplays index with new trip selected
   assert_select "div#page_title", "Trips"
   assert_select "span#triprow1", "test trip 1 by Example user1"
   assert_select "span#triprow2", "(draft) test trip 2 by Example user1"
   assert_select "span#triprow3", "test trip 3 by Example user1"
   assert_select "span#triprow4", "test trip 4 by Example user2"
   assert_select "div#selectedrow1"
   assert_select "span#triprow5", false
   #root can select any of 4
   assert_select "input#selectCurrent", 4
   assert_select "input#Delete", false
   assert_select "a#addbutton", false
end

#cannot select another users trip (user)
test "select another user's trip disallowed (user)" do
   login_as(@testuser2.name, "password")
   assert is_logged_in?
   @testuser2.currenttrip=@testtrip3
   @testuser2.save

   get '/trips'
   assert_response :success

   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'index',
                         commit: 'Select as current' }
   #page reloads
   assert_response :success
   assert_select "div#page_title", "Trips"
   @testuser2.reload
   #but trip not changed
   assert @testuser2.currenttrip_id, @testtrip3.id


   get '/wishlist'
   assert_response :success

   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'wishlist',
                         commit: 'Select as current' }
   #page reloads
   assert_response :success
   assert_select "div#page_title", "My Trips"
   @testuser2.reload
   #but trip not changed
   assert @testuser2.currenttrip_id, @testtrip3.id
end
#cannot select another users trip (guest)
test "select another user's trip disallowed (guest)" do
   add_place_to_trip(@testplace)
   assert is_guest?
   @ourguest=Guest.find_by_id(session[:guest_id])
   old_trip=@ourguest.currenttrip_id
   get '/trips'
   assert_response :success

   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'index',
                         commit: 'Select as current' }
   #page reloads
   assert_response :success
   assert_select "div#page_title", "Trips"
   #but trip not changed
   assert is_guest?
   @ourguest.reload
   assert_equal @ourguest.currenttrip_id, old_trip


   get '/wishlist'
   assert_response :success

   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'wishlist',
                         commit: 'Select as current' }
   #page reloads
   assert_response :success
   assert_select "div#page_title", "My Trips"
   #but trip not changed
   assert_equal @ourguest.currenttrip_id, old_trip
end

#delete a trip (user)
test "delete our trips" do
   #DELETE TRIP NOT CURRENT
   login_as(@testuser.name, "password")
   assert is_logged_in?
   @testuser.currenttrip=@testtrip3
   @testuser.save
   oldid=@testtrip1.id
   oldcnt=Trip.count

   get '/wishlist'
   assert_response :success
   assert_select "span#triprow3"
   assert_select "span#triprow4", false

   post '/trips/move', { selected_id:  @testtrip1.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }
   #page reloads
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select  "div.alert", "Trip deleted"

   @testuser.reload
   #but trip not changed
   assert_equal @testuser.currenttrip_id, @testtrip3.id
   #trip and details deleted
   assert_not Trip.find_by_id(oldid)
   assert_equal TripDetail.where(:trip_id => oldid).count, 0
   assert_equal Trip.count, oldcnt-1
   assert_select "span#triprow2"
   assert_select "span#triprow3", false


   #DELETE TRIP CURRENT
 
   oldid=@testtrip3.id
   oldcnt=Trip.count

   get '/wishlist'
   assert_response :success
                    
   post '/trips/move', { selected_id:  @testtrip3.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }    
   #page reloads      
   assert_response :success
   assert_select "div#page_title", "My Trips"        
   assert_select  "div.alert", "Trip deleted"

   @testuser.reload
   #currenttrip changed to last remaining trip for this user
   assert_equal @testuser.currenttrip_id, @testtrip2.id
   #trip and details deleted
   assert_not Trip.find_by_id(oldid)
   assert_equal TripDetail.where(:trip_id => oldid).count, 0
   assert_equal Trip.count, oldcnt-1
   assert_select "span#triprow1"
   assert_select "span#triprow2", false
   

   #DELETE TRIP CURRENT, LAST
 
   oldid=@testtrip2.id
   oldcnt=Trip.count

   get '/wishlist'
   assert_response :success
                    
   post '/trips/move', { selected_id:  @testtrip2.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }    
   #page reloads      
   assert_response :success
   assert_select "div#page_title", "My Trips"        
   assert_select  "div.alert", "Trip deleted"

   @testuser.reload
   #currenttrip changed to new trip
   assert_not_equal @testuser.currenttrip_id, @testtrip2.id
   assert_equal @testuser.currenttrip_id, Trip.last.id
   #trip and details deleted put nrw one added
   assert_not Trip.find_by_id(oldid)
   assert_equal TripDetail.where(:trip_id => oldid).count, 0
   assert_equal Trip.count, oldcnt
   assert_select "span#triprow1", "(draft) Default by Example user1"
   assert_select "span#triprow2", false

   #new trip created
   newtrip=Trip.find_by_id(@testuser.currenttrip_id)
   assert_equal newtrip.name, "Default"
   assert_equal newtrip.createdBy_id, @testuser.id

end

#cannot delete another users trip (user)
test "cannot delete others trips" do
   #DELETE TRIP NOT CURRENT
   login_as(@testuser.name, "password")
   assert is_logged_in?
   @testuser.currenttrip=@testtrip3
   @testuser.save
   oldid=@testtrip4.id
   oldcnt=Trip.count

   get '/wishlist'
   assert_response :success
   assert_select "span#triprow3"
   assert_select "span#triprow4", false

   post '/trips/move', { selected_id:  @testtrip4.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }
   #page reloads
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select  "div.alert", "Error: You cannot delete this trip"

   #trip and details deleted
   assert Trip.find_by_id(oldid)
   assert_equal Trip.count, oldcnt
   assert_select "span#triprow3"
   assert_select "span#triprow4", false
end


#delete a trip (guest)
test "delete our trip (guest)" do
   add_route_to_trip_fw(@testroute)
   @ourguest=Guest.find_by_id(session[:guest_id])

   assert is_guest?
   trip=@ourguest.currenttrip_id

   #DELETE TRIP CURRENT, LAST

   oldid=trip
   oldcnt=Trip.count

   get '/wishlist'
   assert_response :success

   post '/trips/move', { selected_id:  trip,
                         referring_page: 'wishlist',
                         commit: 'Delete' }
   #page reloads      
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select  "div.alert", "Trip deleted"

   @ourguest.reload
   #currenttrip changed to new trip
   assert_not_equal @ourguest.currenttrip_id, trip
   assert_equal @ourguest.currenttrip_id, Trip.last.id
   #trip and details deleted put nrw one added
   assert_not Trip.find_by_id(oldid)
   assert_equal TripDetail.where(:trip_id => oldid).count, 0
   assert_equal Trip.count, oldcnt
   assert_select "span#triprow1", "(draft) My Trip"
   assert_select "span#triprow2", false

   #new trip created
   newtrip=Trip.find_by_id(@ourguest.currenttrip_id)
   assert_equal newtrip.name, "My Trip"
   assert_equal newtrip.createdBy_id, nil
end

#cannot delete others trip (guest)
test "cannot delete others trip (guest)" do
   add_route_to_trip_fw(@testroute)
   @ourguest=Guest.find_by_id(session[:guest_id])

   assert is_guest?
   trip=@ourguest.currenttrip_id

   #DELETE TRIP CURRENT, LAST

   oldid=@testtrip2.id
   oldcnt=Trip.count

   get '/wishlist'
   assert_response :success
  
   post '/trips/move', { selected_id:  @testtrip2.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }

   @ourguest.reload
   assert_equal @ourguest.currenttrip_id, trip
   #page reloads
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select  "div.alert", "Error: You cannot delete this trip"

   #trip and details not deleted
   assert Trip.find_by_id(oldid)
   assert Trip.find_by_id(trip)
   assert_equal Trip.count, oldcnt
   assert_select "span#triprow1"
   assert_select "span#triprow2", false


end

#delete anothers users trip (root)
  #nb check no users have this as current_trip afterwards
test "delete others trips as root" do
   #assign trips tto users
   @testuser.currenttrip=@testtrip3
   @testuser.save
   @testuser2.currenttrip=@testtrip4
   @testuser2.save
   @testtrip5=Trip.create(name: "test guest trip")
   @td5a=TripDetail.create(trip_id: @testtrip5.id, route_id: @testroute2.id, order: 1)

   @ourguest=Guest.create(id: 2, currenttrip_id: @testtrip5.id)

   #login as root
   login_as(@testuser3.name, "password")
   assert is_logged_in?


   oldid=@testtrip3.id
   oldcnt=Trip.count
   
   post '/trips/move', { selected_id:  @testtrip3.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }
   #page reloads
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select  "div.alert", "Trip deleted"

   @testuser.reload
   #currenttrip changed to nother trip for this user
   assert_not_equal @testuser.currenttrip_id, @testtrip3.id

   #trip and details deleted
   assert_not Trip.find_by_id(oldid)
   assert_equal TripDetail.where(:trip_id => oldid).count, 0
   assert_equal Trip.count, oldcnt-1

   #DELETE TRIP CURRENT, LAST for user

   oldid=@testtrip4.id
   oldcnt=Trip.count

   post '/trips/move', { selected_id:  @testtrip4.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }
   #page reloads      
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select  "div.alert", "Trip deleted"

   @testuser2.reload
   #currenttrip changed to new trip
   assert_not_equal @testuser2.currenttrip_id, @testtrip4.id
   assert_equal @testuser2.currenttrip_id, Trip.last.id
   #trip and details deleted put nrw one added
   assert_not Trip.find_by_id(oldid)
   assert_equal TripDetail.where(:trip_id => oldid).count, 0
   assert_equal Trip.count, oldcnt

   #new trip created
   newtrip=Trip.find_by_id(@testuser2.currenttrip_id)
   assert_equal newtrip.name, "Default"
   assert_equal newtrip.createdBy_id, @testuser2.id

   #delete a guests trip
   post '/trips/move', { selected_id:  @testtrip5.id,
                         referring_page: 'wishlist',
                         commit: 'Delete' }
   #page reloads      
   assert_response :success
   assert_select "div#page_title", "My Trips"
   assert_select  "div.alert", "Trip deleted"

   @ourguest.reload
   #currenttrip changed to new trip
   assert_not_equal @ourguest.currenttrip_id, @testtrip5.id
   assert_equal @ourguest.currenttrip_id, Trip.last.id
   #trip and details deleted put nrw one added
   assert_not Trip.find_by_id(oldid)
   assert_equal TripDetail.where(:trip_id => oldid).count, 0
   assert_equal Trip.count, oldcnt

   #new trip created
   newtrip=Trip.find_by_id(@ourguest.currenttrip_id)
   assert_equal newtrip.name, "My Trip"
   assert_equal newtrip.createdBy_id, nil
end

#add a trip (user)
test "Add a trip as user" do
   login_as(@testuser.name, "password")
   assert is_logged_in?
   @testuser.currenttrip=@testtrip3
   @testuser.save
   oldid=@testtrip1.id
   oldcnt=Trip.count

   get '/wishlist'
   assert_response :success
   assert_select "span#triprow3"
   assert_select "span#triprow4", false

   #click add
   get '/trips/new'
   assert_response :success
   assert_select  "div.alert", "New trip created and assigned as your current trip"


   # new trip created
   assert_equal Trip.count, oldcnt+1
   @testuser.reload
   assert_equal @testuser.currenttrip_id, Trip.last.id
   assert_equal @testuser.currenttrip.name, "Default"

   #redireected to edit page for new trip
   assert_select "form#edit_trip_"+@testuser.currenttrip_id.to_s
   assert_select "input#trip_name[value=?]", "Default"
end

#cannot add a trip (guest, stranger)
test "Cannot add a trip not signed in" do
   oldcnt=Trip.count

   #click add
   get '/trips/new'

   #dedirect to home
   assert_redirected_to signin_path
   follow_redirect!

   # no new trip created
   assert_equal Trip.count, oldcnt

   #GUEST
   add_route_to_trip_fw(@testroute)
   @ourguest=Guest.find_by_id(session[:guest_id])

   assert is_guest?
   trip=@ourguest.currenttrip_id
   oldcnt=Trip.count

   #click add
   get '/trips/new'

   #dedirect to home
   assert_redirected_to signin_path
   follow_redirect!

   # no new trip created
   assert_equal Trip.count, oldcnt

end

#user profile -> trips
 #not registered - all this user's, no others
 #guest - all this user's, no others
 #user - all this user's, no others

test "show users trips in user profile (stranger)" do
   get '/users/'+URI.escape(@testuser.name)

   assert_response :success
   assert_select "div#page_title", @testuser.name.capitalize
   assert_select "span#triprow1", "(draft) test trip 2 by Example user1"
   assert_select "div#tripstats1", "(updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow2", "test trip 1 by Example user1"
   assert_select "div#tripstats2", "1.0 to 3.0 days | 3.00 km | 3.5 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow3", "test trip 3 by Example user1"
   assert_select "div#tripstats3", "(updated "+Time.now().strftime("%F")+")"

   #no more rows
   assert_select "span#triprow4", false
   # no ticks'
   assert_select "input#selectCurrent", false
   # no delete
   assert_select "input#Delete", false
   # no add
   assert_select "a#addbutton", false
   
end

#home page trips - last 3 by user by date
test "show latest trips in home (stranger)" do
   get '/'

   assert_response :success
   assert_select "span#triprow1", "test trip 4 by Example user2"
   assert_select "div#tripstats1", "2.0 to 4.0 days | 1.00 km | 3.0 DOC hrs (updated "+Time.now().strftime("%F")+")"
   assert_select "span#triprow2", "test trip 3 by Example user1"
   assert_select "div#tripstats2", "(updated "+Time.now().strftime("%F")+")"

   #no more rows
   assert_select "span#triprow3", false
   # no ticks'
   assert_select "input#selectCurrent", false
   # no delete
   assert_select "input#Delete", false
   # no add
   assert_select "a#addbutton", false

end


end
