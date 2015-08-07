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
                               role_id: @testrole.id,
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

def create_place(name,type)
   Place.create(name: name, createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: type)
end

def create_route(name,startplace,endplace)
   Route.create(name: name, createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: startplace.id, endplace_id: endplace.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
end

def link_places(place1, place2)
  @l1=Link.create(item_id:place1.id, item_type: 'place', baseItem_id:place2.id, baseItem_type: "place", item_url: nil )
end

def link_place_to_route(place1, route1)
  @l1=Link.create(item_id:place1.id, item_type: 'place', baseItem_id:route1.id, baseItem_type: "route", item_url: nil )
end

def loop_network

#     /--H6--\
#     |      |
#H1--H2--H3--H4--R5
  @pl1=Place.create(name: "H1", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl2=Place.create(name: "H2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl3=Place.create(name: "H3", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl4=Place.create(name: "H4", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl5=Place.create(name: "R5", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Roadend")
  @pl6=Place.create(name: "H6", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")


  @rt1=Route.create(name: "rt1", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl1.id, endplace_id: @pl2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt2=Route.create(name: "rt2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl2.id, endplace_id: @pl3.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt3=Route.create(name: "rt3", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl3.id, endplace_id: @pl4.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt4=Route.create(name: "rt4", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl4.id, endplace_id: @pl5.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt5=Route.create(name: "rt5", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl4.id, endplace_id: @pl6.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt6=Route.create(name: "rt6", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl6.id, endplace_id: @pl2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt1.regenerate_route_index
  @rt2.regenerate_route_index
  @rt3.regenerate_route_index
  @rt4.regenerate_route_index
  @rt5.regenerate_route_index
  @rt6.regenerate_route_index
end

def init_network

#H1--H2--R3--J4--H5--J6--J7
  @pl1=Place.create(name: "H1", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl2=Place.create(name: "H2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl3=Place.create(name: "R3", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Roadend")
  @pl4=Place.create(name: "J4", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Junction")
  @pl5=Place.create(name: "H5", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl6=Place.create(name: "J6", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Junction")
  @pl7=Place.create(name: "H7", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")


  @rt1=Route.create(name: "rt1", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl1.id, endplace_id: @pl2.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt2=Route.create(name: "rt2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl2.id, endplace_id: @pl3.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt3=Route.create(name: "rt3", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl3.id, endplace_id: @pl4.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt4=Route.create(name: "rt4", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl4.id, endplace_id: @pl5.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt5=Route.create(name: "rt5", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl5.id, endplace_id: @pl6.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt6=Route.create(name: "rt6", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl6.id, endplace_id: @pl7.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt1.regenerate_route_index
  @rt2.regenerate_route_index
  @rt3.regenerate_route_index
  @rt4.regenerate_route_index
  @rt5.regenerate_route_index
  @rt6.regenerate_route_index


#R10--H11/C12---H13/C14--R15
#            J18
#             |
#          H16/C17

  @pl10=Place.create(name: "R10", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Roadend")
  @pl11=Place.create(name: "H11", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl12=Place.create(name: "C12", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Campspot")
  @pl13=Place.create(name: "H13", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl14=Place.create(name: "C14", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Campsite")
  @pl15=Place.create(name: "R15", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Roadend")
  @pl16=Place.create(name: "H16", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut")
  @pl17=Place.create(name: "C17", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Campspot")
  @pl18=Place.create(name: "J18", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id, experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Junction")

  @rt10=Route.create(name: "rt10", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl10.id, endplace_id: @pl11.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt11=Route.create(name: "rt11", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl12.id, endplace_id: @pl13.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt12=Route.create(name: "rt12", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl14.id, endplace_id: @pl15.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")
  @rt13=Route.create(name: "rt13", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @pl18.id, endplace_id: @pl16.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A", reverse_description: "Z")

  @l1=Link.create(item_id:@pl11.id, item_type: 'place', baseItem_id:@pl12.id, baseItem_type: "place", item_url: nil )
  @l2=Link.create(item_id:@pl13.id, item_type: 'place', baseItem_id:@pl14.id, baseItem_type: "place", item_url: nil )
  @l3=Link.create(item_id:@pl18.id, item_type: 'place', baseItem_id:@rt11.id, baseItem_type: "route", item_url: nil )
  @l3=Link.create(item_id:@pl16.id, item_type: 'place', baseItem_id:@pl17.id, baseItem_type: "place", item_url: nil )
  @rt10.regenerate_route_index
  @rt11.regenerate_route_index
  @rt12.regenerate_route_index
  @rt13.regenerate_route_index
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

  @testrole = Role.create(name: "user", id: 1)
  @testrole2 = Role.create(name: "root", id: 2)

  @testuser = User.new(name: "Example User1", email: "user1@example.com",
                  password: "password", password_confirmation: "password", firstName: "test1a", lastName: "test1b", role_id: 1, hide_name: true)
  @testuser.activate
  @testuser.save
  @testuser2 = User.new(name: "Example User2", email: "user2@example.com",
                  password: "password", password_confirmation: "password", firstName: "test2a", lastName: "test2b", role_id: 1)
  @testuser2.activate
  @testuser3 = User.new(name: "rootUser", email: "root@example.com",
                  password: "password", password_confirmation: "password", firstName: "root", lastName: "root2", role_id: 2)
  @testuser3.activate
Projection.create(id: 2193, name: "NZTM2000", proj4: "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towg", wkt: "", epsg: 2193)
Projection.create(id: 27200, name: "NZMG49", proj4: "+proj=nzmg +lat_0=-41 +lon_0=173 +x_0=2510000 +y_0=6023150 +ellps=intl +datum=nzgd49 +units=m +no_defs", wkt: "", epsg: 27200)

Projection.create(id: 4326, name: "WGS84", proj4: "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs", wkt: "", epsg: 4326)

PlaceType.create(id:1, name: "Hut", description: "Back country hut open for public use", color: "blue", graphicName: "circle", pointRadius: 3, url: nil, isDest: true, category: "accomodation")
PlaceType.create(id:2, name: "Campsite", description: "Official campsite", color: "cyan", graphicName: "circle", pointRadius: 3, url: nil, isDest: true, category: "accomodation")
PlaceType.create(id:3, name: "Campspot", description: "A viable informal camp spot", color: "green", graphicName: "circle", pointRadius: 3, url: nil, isDest: true, category: "accomodation")
PlaceType.create(id:4,name: "Summit", description: "A peak", color: "#b26b00", graphicName: "triangle", pointRadius: 3, url: nil, isDest: true, category: "summit")
PlaceType.create(id:5,name: "Pass", description: "A trampable pass, col or saddle", color: "#333300", graphicName: "triangle", pointRadius: 3, url: nil, isDest: false, category: "crossing")
PlaceType.create(id:6,name: "Locality", description: "A town, station, or other inhabited locality", color: "black", graphicName: "square", pointRadius: 3, url: nil, isDest: true, category: "other")
PlaceType.create(id:7,name: "Roadend", description: "The point a track leaves a vehicular road", color: "#1a1a1a", graphicName: "square", pointRadius: 3, url: nil, isDest: true, category: "roadend")
PlaceType.create(id:8,name: "Other", description: "Other location forming the start / end of a route", color: "#00003d", graphicName: "square", pointRadius: 3, url: nil, isDest: false, category: "other")
PlaceType.create(id:9,name: "Junction", description: "Track or route junction", color: "#00003d", graphicName: "square", pointRadius: 2, url: nil, isDest: false, category: "other")
PlaceType.create(id:10,name: "Waterbody" , description: "Lake, river, stream, etc", color: "#000099", graphicName: "x", pointRadius: 3, url: nil, isDest: false, category: "scenic")
PlaceType.create(id:11,name: "Rock Biv" , description: "Natural shelter", color: "#414141", graphicName: "circle", pointRadius: 3, url: nil, isDest: false, category: "accomodation")
PlaceType.create(id:12,name: "Bridge" , description: "Bridge", color: "#414141", graphicName: "cross", pointRadius: 3, url: nil, isDest: false, category: "crossing")
PlaceType.create(id:13,name: "River Crossing" , description: "River crossing", color: "#414141", graphicName: "cross", pointRadius: 3, url: nil, isDest: false, category: "crossing")
PlaceType.create(id:14,name: "Lookout" , description: "Lookout or viewing platform", color: "#414141", graphicName: "x", pointRadius: 3, url: nil, isDest: false, category: "scenic")

Routetype.create(id:1, code: "unk", name: "Unknown", description: "Not specified",difficulty: 0, linecolor: "#660066", linetype: "solid")
Gradient.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
Terrain.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
Alpine.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
Alpinew.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
River.create(id:1, name: "Unknown", description: "Not specified",difficulty: 0)
RouteImportance.create(id:1, name: "Primary, mapped", description: "Formal route, on maps, principal access to hut or along range / catchment", importance: 1)
Routetype.create(id:2, code: "rd", name: "Road", description: "Formed road, 4WD track, etc",difficulty: 1, linecolor: "#660066", linetype: "solid")
Gradient.create(id:2, name: "Flat", description: "Flat", difficulty: 1)
Terrain.create(id:2, name: "Easy", description: "Grass / prepared surface", difficulty: 1)
Alpine.create(id:2, name: "None", description: "No alpine skills required", difficulty: 1)
Alpinew.create(id:2, name: "None", description: "No alpine skills required", difficulty: 1)
River.create(id:2, name: "None", description: "No unbridged river crossings", difficulty: 1)
RouteImportance.create(id:2, name: "Primary, unmapped" , description: "Route not on maps, but is principal access to hut or along range / catchment", importance: 2)
RouteImportance.create(id:3,name: "Secondary, mapped", description: "Formal route, on maps, an alternative recognised access to hut or along range / catchment", importance: 3)

Routetype.create(id:3,code: "sw", name: "Surfaced walkway", description: "Gravelled / board-walked walking track for all abilities",difficulty: 2, linecolor: "#660033", linetype: "solid")
Gradient.create(id:3,name: "Gentle", description: "Gentle slopes", difficulty: 2)
Terrain.create(id:3,name: "Easy-moderate", description: "Tussock / river-gravel / open bush / cut track", difficulty: 3)
Alpine.create(id:3, name: "Alpine weather", description: "Tramp on open tops, exposed to alpine weather", difficulty: 2) 
Alpinew.create(id:3,name: "Snow/ice underfoot", description: "Snow/ice likely on track", difficulty: 2)
River.create(id:3, name: "Streams", description: "Small streams, danger only in extreme weather", difficulty: 2)


if !@skiproutes then
  @testplace=Place.create(name: "testplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut", place_owner: "DOC", altitude: "123", description:"test place1 description")
  PlaceInstance.create(name: "testplace", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)',place_type: "Hut", place_id: @testplace.id)

  @testplace2=Place.create(name: "testplacei2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-2015", x: 2900000, y: 5500000, projection_id: 2193, location: 'POINT(173 -46)',place_type: "Hut")
  PlaceInstance.create(name: "testplacei2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-2015", x: 2900000, y: 5500000, projection_id: 2193, location: 'POINT(173 -46)',place_type: "Hut", place_id: @testplace2.id)
  @testplace3=Place.create(name: "testplacei3", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 2900000, y: 5600000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut")
  PlaceInstance.create(name: "testplacei2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 2900000, y: 5600000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut", place_id: @testplace3.id)
  @testplace4=Place.create(name: "testplacei4", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 2900000, y: 5700000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut")
  PlaceInstance.create(name: "testplacei2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", x: 2900000, y: 5700000, projection_id: 2193, location: 'POINT(173 -47)',place_type: "Hut", place_id: @testplace4.id)
  @testroute=Route.new(name: "test1", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: true, startplace_id: @testplace3.id, endplace_id: @testplace4.id, routetype_id: 2, gradient_id: 2, river_id: 2, alpinesummer_id: 2,alpinewinter_id: 2,terrain_id: 2, via: "track1", importance_id: 2, time: 3, location: 'LINESTRING(175 -49 300,177 -49 400)', distance: 1, description: "A"*1000, reverse_description: "Z"*1000, winterdescription: 'X'*1000)
  @testroute2=Route.new(name: "test2", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-2015 12:45", published: true, startplace_id: @testplace4.id, endplace_id: @testplace.id, routetype_id: 3, gradient_id: 3, river_id: 3, alpinesummer_id: 3,alpinewinter_id: 3,terrain_id: 3, via: "track2", importance_id: 3, time: 0.5,  location: 'LINESTRING(176 -50 100,177 -50 200)', distance: 2, description: "B"*1000, reverse_description: "Y"*1000)
  @testroute3=Route.create(name: "test3", createdBy_id: @testuser.id, updatedBy_id:  @testuser.id,experienced_at: "01-01-1900", published: false, startplace_id: @testplace4.id, endplace_id: @testplace.id, via: "track3",  routetype_id: 1, gradient_id: 1, river_id: 1, alpinesummer_id: 1,alpinewinter_id: 1,terrain_id: 1,  importance_id: 1)

    @testroute.calc_altgain
    @testroute.calc_altloss
    @testroute.calc_maxalt
    @testroute.calc_minalt
    @testroute.save
    @testroute2.calc_altgain
    @testroute2.calc_altloss
    @testroute2.calc_maxalt
    @testroute2.calc_minalt
    @testroute2.save
  @testtrip1=Trip.create(name: "test trip 1", createdBy_id: @testuser.id, lengthmin: 1, lengthmax: 3, published: true, description: "test trip 1 description")
  @td1a=TripDetail.create(trip_id: @testtrip1.id, place_id: @testplace.id, order: 1)
  @td1b=TripDetail.create(trip_id: @testtrip1.id, route_id: @testroute.id, order: 2)
  @td1c=TripDetail.create(trip_id: @testtrip1.id, place_id: @testplace2.id, order: 3)
  @td1d=TripDetail.create(trip_id: @testtrip1.id, route_id: @testroute2.id, order: 4)

  @testtrip2=Trip.create(name: "test trip 2", createdBy_id: @testuser.id, )

  @testtrip3=Trip.create(name: "test trip 3", createdBy_id: @testuser.id, published: true, description: "test trip 3 description")
  @td3a=TripDetail.create(trip_id: @testtrip3.id, place_id: @testplace2.id, order: 1)

  @testtrip4=Trip.create(name: "test trip 4", createdBy_id: @testuser2.id, lengthmin: 2, lengthmax: 4, published: true, description: "test trip 4 description")
  @td4a=TripDetail.create(trip_id: @testtrip4.id, route_id: -@testroute.id, order: 1)
  
  @teststory1=Report.create(name:"Test report 1", description: "Test report 1 description", createdBy_id: @testuser.id, updatedBy_id: @testuser.id)
  @teststory2=Report.create(name:"Test report 2", description: "Test report 2 description", createdBy_id: @testuser.id, updatedBy_id: @testuser.id)
  @testphoto1=Photo.create(name:"Test photo 1", description: "Test photo 1 description", createdBy_id: @testuser.id, author: "A. Photographer", taken_at: "2015-01-01", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)', image_file_name: 'test')
  @testphoto2=Photo.create(name:"Test photo 2", description: "Test photo 2 description", createdBy_id: @testuser.id, author: "A. Photographer", taken_at: "2015-01-01", x: 2900000, y: 5400000, projection_id: 2193, location: 'POINT(173 -45)', image_file_name: 'test')
end
end

end
