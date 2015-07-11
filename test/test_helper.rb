ENV["RAILS_ENV"] = "test"
#ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

def add_place_to_trip(place)
    patch 'places/'+place.id.to_s, add: "Add to trip"
    #check we created gues, created trip, added to trip
    assert (is_guest? or is_logged_in?)
end

def add_route_to_trip_fw(route)
    patch 'routes/'+route.id.to_s, addfw: "Add to trip"
    #check we created gues, created trip, added to trip
    assert (is_guest? or is_logged_in?)
end

def add_route_to_trip_rv(route)
    patch 'routes/'+route.id.to_s, addrv: "Add to trip"
    #check we created gues, created trip, added to trip
    assert (is_guest? or is_logged_id?)
end

  def sign_up_as(user, password)

   get '/signup'
   post users_path, user: { name:  user,
                               email: user+"@invalid.net ",
                               firstName: " test 1 ",
                               lastName: " test 2 ",
                               role_id: @role.id,
                               password:              password,
                               password_confirmation: password,
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
  end

  def login_as(user,password)
     get signin_path
     post sessions_path, session: { email: user, password: password }
  end
  # Returns true if a test user is logged in.
  def is_logged_in?
   !session[:user_id].nil?
  end

  def is_guest?
   !session[:guest_id].nil?
  end

def init
    @base_title = "NZ Route Guides"
Securityquestion.create(question:"hooves on a horse", answer: 4)
Securityquestion.create(question:"toes on a man's foot", answer: 5)
Securityquestion.create(question:"fingers on two hands", answer: 10)
Securityquestion.create(question:"wheels on a bicycle", answer: 2)
Securityquestion.create(question:"millimeters in a centimeter", answer: 10)
Securityquestion.create(question:"inches in a foot", answer: 12)
Securityquestion.create(question:"feet in a yard", answer: 3)
Securityquestion.create(question:"letters in the English alphabet", answer: 26)
Securityquestion.create(question:"pins on an NZ plug", answer: 3)
Securityquestion.create(question:"minutes in a quarter hour", answer: 15)
Securityquestion.create(question:"ears on a dog", answer: 2)
Securityquestion.create(question:"wheels on a tricycle", answer: 3)
Securityquestion.create(question:"points for a try (union)", answer: 5)
Securityquestion.create(question:"points for a drop goal (union)", answer: 3)
Securityquestion.create(question:"wheels on a quad-bike", answer: 4)
Securityquestion.create(question:"suits in a pack of cards", answer: 4)
Securityquestion.create(question:"sides on a pentagon", answer: 5)
Securityquestion.create(question:"sides on a hexagon", answer: 6)
Securityquestion.create(question:"thumbs on severn hands", answer: 7)
Securityquestion.create(question:"legs on three cats", answer: 12)
Securityquestion.create(question:"ears on four dogs", answer: 8)
Securityoperator.create(operator:" and I add ", sign: 1)
Securityoperator.create(operator:" and I get another ", sign: 1)
Securityoperator.create(operator:" and I find ", sign: 1)
Securityoperator.create(operator:" and I subtract ", sign: -1)
Securityoperator.create(operator:" and I take away ", sign: -1)
Securityoperator.create(operator:" and I lose ", sign: -1)
Securityoperator.create(operator:" and someone steals ", sign: -1)
Securityoperator.create(operator:" and someone gives me ", sign: 1)

  @role = Role.create(name: "user", id: 1)
  @role2 = Role.create(name: "root", id: 2)

  @user = User.new(name: "Example User1", email: "user1@example.com",
                  password: "password", password_confirmation: "password", firstName: "test1a", lastName: "test1b", role_id: 1, hide_name: true)
  @user.activate
  @user.save
  @user2 = User.new(name: "Example User2", email: "user2@example.com",
                  password: "password", password_confirmation: "password", firstName: "test2a", lastName: "test2b", role_id: 1)
  @user2.activate
  @user3 = User.new(name: "rootUser", email: "root@example.com",
                  password: "password", password_confirmation: "password", firstName: "root", lastName: "root2", role_id: 2)
  @user3.activate
Projection.create(id: 2193, name: "NZTM2000", proj4: "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towg", wkt: "", epsg: 2193)
Projection.create(id: 4326, name: "WGS84", proj4: "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs", wkt: "", epsg: 4326)

PlaceType.create(id:1, name: "Hut", description: "Back country hut open for public use", color: "blue", graphicName: "circle", pointRadius: 3, url: nil, isDest: true, category: "accomodation")
Routetype.create(id:1, code: "unk", name: "Unknown", description: "Not specified",difficulty: 0, linecolor: "#660066", linetype: "solid")
Gradient.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
Terrain.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
Alpine.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
Alpinew.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
River.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
RouteImportance.create(id:1, name: "Primary, mapped", description: "Formal route, on maps, principal access to hut or along range / catchment", importance: 1)
PlaceType.create(id:2, name: "Campsite", description: "Official campsite", color: "cyan", graphicName: "circle", pointRadius: 3, url: nil, isDest: true, category: "accomodation")
Routetype.create(id:2, code: "rd", name: "Road", description: "Formed road, 4WD track, etc",difficulty: 1, linecolor: "#660066", linetype: "solid")
Gradient.create(id:2, name: "Flat", description: "Flat", difficulty: 1)
Terrain.create(id:2, name: "Easy", description: "Grass / prepared surface", difficulty: 1)
Alpine.create(id:2, name: "None", description: "No alpine skills required", difficulty: 1)
Alpinew.create(id:2, name: "None", description: "No alpine skills required", difficulty: 1)
River.create(id:2, name: "None", description: "No unbridged river crossings", difficulty: 1)
RouteImportance.create(id:2, name: "Primary, unmapped" , description: "Route not on maps, but is principal access to hut or along range / catchment", importance: 2)
RouteImportance.create(id:3,name: "Secondary, mapped", description: "Formal route, on maps, an alternative recognised access to hut or along range / catchment", importance: 3)

PlaceType.create(id:3, name: "Campspot", description: "A viable informal camp spot", color: "green", graphicName: "circle", pointRadius: 3, url: nil, isDest: true, category: "accomodation")
Routetype.create(id:3,code: "sw", name: "Surfaced walkway", description: "Gravelled / board-walked walking track for all abilities",difficulty: 2, linecolor: "#660033", linetype: "solid")
Gradient.create(id:3,name: "Gentle", description: "Gentle slopes", difficulty: 2)
Terrain.create(id:3,name: "Easy-moderate", description: "Tussock / river-gravel / open bush / cut track", difficulty: 3)
Alpine.create(id:3, name: "Alpine weather", description: "Tramp on open tops, exposed to alpine weather", difficulty: 2) 
Alpinew.create(id:3,name: "Snow/ice underfoot", description: "Snow/ice likely on track", difficulty: 2)
River.create(id:3, name: "Streams", description: "Small streams, danger only in extreme weather", difficulty: 2)


  @place=Place.create(name: "testplace", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  PlaceInstance.create(name: "testplace", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut", place_id: @place.id)

  @place2=Place.create(name: "testplacei2", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5500000, projection_id: 2193, location: 'POINT(173 -46)',place_type: "Hut")
  PlaceInstance.create(name: "testplacei2", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5500000, projection_id: 2193, location: 'POINT(173 -46)',place_type: "Hut", place_id: @place2.id)
  @place3=Place.create(name: "testplacei3", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5600000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut")
  PlaceInstance.create(name: "testplacei2", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5600000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut", place_id: @place3.id)
  @place4=Place.create(name: "testplacei4", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5700000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut")
  PlaceInstance.create(name: "testplacei2", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", x: 2900000, y: 5700000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut", place_id: @place4.id)
  @route=Route.create(name: "test1", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", published: true, startplace_id: @place3.id, endplace_id: @place4.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A"*1000)
  @route2=Route.create(name: "test2", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", published: true, startplace_id: @place4.id, endplace_id: @place.id, routetype_id: 3, gradient_id: 3, river_id: 3, alpinesummer_id: 3,alpinewinter_id: 3,terrain_id: 3, via: "track2", importance_id: 3, time: 0.5,  location: 'LINESTRING(176 -50 100,177 -50 200)', distance: 2, description: "B"*1000)
  @route3=Route.create(name: "test3", createdBy_id: @user.id, updatedBy_id:  @user.id,experienced_at: "01-01-1900", published: false, startplace_id: @place4.id, endplace_id: @place.id, via: "track3",  routetype_id: 1, gradient_id: 1, river_id: 1, alpinesummer_id: 1,alpinewinter_id: 1,terrain_id: 1,  importance_id: 1)

    @route.calc_altgain
    @route.calc_altloss
    @route.calc_maxalt
    @route.calc_minalt
    @route.save
    @route2.calc_altgain
    @route2.calc_altloss
    @route2.calc_maxalt
    @route2.calc_minalt
    @route2.save
  @trip1=Trip.create(name: "test trip 1", createdBy_id: @user.id, lengthmin: 1, lengthmax: 3, published: true, description: "test trip 1 description")
  @td1a=TripDetail.create(trip_id: @trip1.id, place_id: @place.id, order: 1)
  @td1b=TripDetail.create(trip_id: @trip1.id, route_id: @route.id, order: 2)
  @td1c=TripDetail.create(trip_id: @trip1.id, place_id: @place2.id, order: 3)
  @td1d=TripDetail.create(trip_id: @trip1.id, route_id: @route2.id, order: 4)

  @trip2=Trip.create(name: "test trip 2", createdBy_id: @user.id, )

  @trip3=Trip.create(name: "test trip 3", createdBy_id: @user.id, published: true, description: "test trip 3 description")
  @td3a=TripDetail.create(trip_id: @trip3.id, place_id: @place2.id, order: 1)

  @trip4=Trip.create(name: "test trip 4", createdBy_id: @user2.id, lengthmin: 2, lengthmax: 4, published: true, description: "test trip 4 description")
  @td4a=TripDetail.create(trip_id: @trip4.id, route_id: @route.id, order: 1)
end

end
