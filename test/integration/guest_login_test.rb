require 'test_helper'

class GuestLoginTest < ActionDispatch::IntegrationTest

def setup
   init()
end

  test "not a guest by default" do
    get root_path
    assert_not is_guest?
    assert_select "a[href=?]", '/currenttrip', false
  end

  test "add to trip (place) creates guest" do
    get root_path
    assert_not is_guest?
    get '/places/'+@testplace.id.to_s
    assert_template 'places/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    patch 'places/'+@testplace.id.to_s, add: "Add to trip"
    #check we created gues, created trip, added to trip
    assert Guest.count==guestCnt+1
    assert Trip.count==tripCnt+1
    assert is_guest?
    guest=Guest.last
    trip=guest.currenttrip
    assert trip.trip_details.first.place_id=@testplace.id
    assert guest.currenttrip_id==Trip.last.id
    follow_redirect!
    assert_template 'places/show'
    assert_select  "div.alert", "Added place to trip"
   
    #navigate to my trip
    get '/currenttrip' 

    assert_template 'trips/show'
    assert_select "div#place_details>div.erow>div.sectiontitle25", {:count =>1, :text=> @testplace.name+" (DOC Hut)"}
    assert_select "div#place1"
    assert_select "div#place2", false


    #2nd add adds but doesnt create new guest
    get '/places/'+@testplace2.id.to_s
    assert_template 'places/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    tripDCnt=TripDetail.count
    patch 'places/'+@testplace2.id.to_s, add: "Add to trip"
    #check we created gues, created trip, added to trip
    assert Guest.count==guestCnt
    assert Trip.count==tripCnt
    assert TripDetail.count==tripDCnt+1
    assert is_guest?
    assert trip.trip_details.first.place_id=@testplace.id
    assert trip.trip_details.last.place_id=@testplace2.id
    assert guest.currenttrip_id==Trip.last.id
    assert_template 'places/show'
    assert_select  "div.alert", "Added place to trip"

    #navigate to my trip
    get '/currenttrip'
    assert_template 'trips/show'
    #erify 2 places listed
    assert_select "div#place1"
    assert_select "div#place2"
    assert_select "div#place3", false

  end

  test "add to trip (route) creates guest" do
    get root_path
    assert_not is_guest?
    get '/routes/'+@testroute.id.to_s
    assert_template 'routes/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    patch 'routes/'+@testroute.id.to_s, addfw: "Add to trip"
    #check we created gues, created trip, added to trip
    assert Guest.count==guestCnt+1
    assert Trip.count==tripCnt+1
    assert is_guest?
    guest=Guest.last
    trip=guest.currenttrip
    assert trip.trip_details.first.route_id=@testroute.id
    assert guest.currenttrip_id==Trip.last.id
    follow_redirect!
    assert_template 'routes/show'
    assert_select  "div.alert", "Added route to trip"
   
    #navigate to my trip
    get '/currenttrip' 

    assert_template 'trips/show'
    #Will be Draft/n/t<title>
    thisname=@testroute.startplace.name+" to "+@testroute.endplace.name+" via "+@testroute.via
    assert_select "div#route_details>div.erow>div.sectiontitle25", {:count =>1, :text=> /.*#{thisname}/}
    assert_select "div#route1"
    assert_select "div#route2", false


    #2nd add adds but doesnt create new guest
    get '/routes/'+@testroute2.id.to_s
    assert_template 'routes/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    tripDCnt=TripDetail.count
    patch 'routes/'+@testroute2.id.to_s, addfw: "Add to trip"
    #check we created gues, created trip, added to trip
    assert Guest.count==guestCnt
    assert Trip.count==tripCnt
    assert TripDetail.count==tripDCnt+1
    assert is_guest?
    assert trip.trip_details.first.route_id=@testroute.id
    assert trip.trip_details.last.route_id=@testroute2.id
    assert guest.currenttrip_id==Trip.last.id
    assert_template 'routes/show'
    assert_select  "div.alert", "Added route to trip"

    #navigate to my trip
    get '/currenttrip'
    assert_template 'trips/show'
    #erify 2 places listed
    assert_select "div#route1"
    assert_select "div#route2"
    assert_select "div#route3", false

  end
  test "add (reverse) to trip (route) creates guest" do
    get root_path
    assert_not is_guest?
    get '/routes/'+@testroute.id.to_s
    assert_template 'routes/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    patch 'routes/'+@testroute.id.to_s, addrv: "Add to trip"
    #check we created gues, created trip, added to trip
    assert Guest.count==guestCnt+1
    assert Trip.count==tripCnt+1
    assert is_guest?
    guest=Guest.last
    trip=guest.currenttrip
    assert trip.trip_details.first.route_id==-@testroute.id
    assert guest.currenttrip_id==Trip.last.id
    follow_redirect!
    assert_template 'routes/show'
    assert_select  "div.alert", "Added route to trip"
   
    #navigate to my trip
    get '/currenttrip' 

    assert_template 'trips/show'
    #Will be Draft/n/t<title>
    revname=@testroute.endplace.name+" to "+@testroute.startplace.name+" via "+@testroute.via
    assert_select "div#route_details>div.erow>div.sectiontitle25", {:count =>1, :text=> /.*#{revname}/}
    assert_select "div#route1"
    assert_select "div#route2", false


    #2nd add adds but doesnt create new guest
    get '/routes/'+@testroute2.id.to_s
    assert_template 'routes/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    tripDCnt=TripDetail.count
    patch 'routes/'+@testroute2.id.to_s, addrv: "Add to trip"
    #check we created gues, created trip, added to trip
    assert Guest.count==guestCnt
    assert Trip.count==tripCnt
    assert TripDetail.count==tripDCnt+1
    assert is_guest?
    assert trip.trip_details.first.route_id==-@testroute.id
    assert trip.trip_details.last.route_id==-@testroute2.id
    assert guest.currenttrip_id==Trip.last.id
    assert_template 'routes/show'
    assert_select  "div.alert", "Added route to trip"

    #navigate to my trip
    get '/currenttrip'
    assert_template 'trips/show'
    #erify 2 places listed
    assert_select "div#route1"
    assert_select "div#route2"
    assert_select "div#route3", false

  end

  test "guest expiry" do
    @testtrip=Trip.create(name: "Test trip", created_at: 4.months.ago, updated_at: 4.months.ago)
    @guest=Guest.create(created_at: 4.months.ago, updated_at: 4.months.ago, currenttrip_id: @testtrip.id)
    @td1=TripDetail.create(trip_id: @testtrip.id, place_id: @testplace.id, order: 1)
    @td2=TripDetail.create(trip_id: @testtrip.id, route_id: @testroute.id, order: 2)
    @testtrip.reload
    @guest.reload
    assert @testtrip.created_at<=4.months.ago()
    assert @guest.created_at<=4.months.ago()

    #now trigger new guest 
    get root_path
    assert_not is_guest?
    get '/routes/'+@testroute.id.to_s
    assert_template 'routes/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    tdCnt=TripDetail.count
    patch 'routes/'+@testroute.id.to_s, addrv: "Add to trip"
    #check we created guest and deleted 1 guest, created /deleted trip, added 1 element to trip, deleted 2
    assert_equal Guest.count, guestCnt
    assert_equal Trip.count, tripCnt
    assert_equal TripDetail.count, tdCnt-1
    assert is_guest?
    guest=Guest.last
    trip=guest.currenttrip
    assert_equal trip.trip_details.first.route_id, -@testroute.id
    assert_equal guest.currenttrip_id, Trip.last.id
    follow_redirect!
    assert_response :success
    assert_template 'routes/show'
    assert_select  "div.alert", "Added route to trip"

    #verify old trip and guestgone
    assert_not Trip.find_by_id(@testtrip.id)
    assert_not Guest.find_by_id(@guest.id)
    assert_not TripDetail.find_by_id(@td1.id)
    assert_not TripDetail.find_by_id(@td2.id)
  end

#guest user signs up. Remains guest, but trip associated with user too
  test "geust user signs up" do
    get root_path
    assert_not is_guest?
    get '/routes/'+@testroute.id.to_s
    assert_template 'routes/show'
    guestCnt=Guest.count
    tripCnt=Trip.count
    tdCnt=TripDetail.count
    patch 'routes/'+@testroute.id.to_s, addfw: "Add to trip"
    #check we created guest and deleted 1 guest, created /deleted trip, added 1 element to trip, deleted 2
    guest=Guest.last
    assert_equal Guest.count, guestCnt+1
    assert_equal Trip.count, tripCnt+1
    assert_equal TripDetail.count, tdCnt+1
    assert is_guest?
    #now signup
    sign_up_as("test6", "password")
    user = assigns(:user)

    #still guest and can still view trip
    assert is_guest?
    assert_not  is_logged_in?
   
    #no new trips created
    assert_equal Trip.count, tripCnt+1
    assert_equal TripDetail.count, tdCnt+1
    
    #our trip still belongs to us and new user
    assert_equal guest.currenttrip.createdBy_id, user.id

    #guest can still view trip 
    get '/currenttrip' 
    assert_template 'trips/show'
    thisname=@testroute.startplace.name+" to "+@testroute.endplace.name+" via "+@testroute.via
    assert_select "div#route_details>div.erow>div.sectiontitle25", {:count =>1, :text=> /.*#{thisname}/}
    assert_select "div#route1"
    assert_select "div#route2", false
    
    #activate account and log in 
    get edit_account_activation_path(id: user.activation_token, email: user.email)
    follow_redirect!

    #is now user and not guiest
    assert is_logged_in?
    assert_not is_guest?

    #guest has been deleted
    assert_equal Guest.count, guestCnt
    
    #and our trip is ours
    get '/currenttrip' 
    assert_template 'trips/show'
    assert_select "div#route_details>div.erow>div.sectiontitle25", {:count =>1, :text=> /.*#{thisname}/}
    assert_select "div#route1"
    assert_select "div#route2", false
        
  end


end
