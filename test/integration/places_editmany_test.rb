require 'test_helper'

class PlacesEditmanyTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "view new many place as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/xpn'
    assert :success
    assert_template 'routes/show_many'
  
    #display
    assert_select "input#place_name"
    assert_select "input#place_name[value=?]",  /./, false
    assert_select "input#place_experienced_at"
    assert_select "input#place_experienced_at[value=?]",  /./, false
    assert_select "input#place_place_owner"
    assert_select "input#place_place_owner[value=?]",  /./, false
    assert_select "textarea#place_description",  ""
    assert_select 'option[value="2193"]' do |t| #default projection 2193
       assert_select %q{option[selected="selected"]}
    end
    assert_select "input#place_x"
    assert_select "input#place_x[value=?]",  /./, false
    assert_select "input#place_y"
    assert_select "input#place_y[value=?]",  /./, false
    assert_select "input#place_altitude"
    assert_select "input#place_altitude[value=?]", /./, false
end

test "view edit many place as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/xpe'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'
  
    #display
    assert_select "input#place_name[value=?]",  "testplace"
    assert_select "input#place_experienced_at[value=?]",  "1900-01-01"
    assert_select 'option[value="Hut"]' do |t|
       assert_select %q{option[selected="selected"]}
    end
    assert_select "input#place_place_owner[value=?]",  "DOC"
    assert_select "textarea#place_description",  "test place1 description"
    assert_select 'option[value="2193"]' do |t|
       assert_select %q{option[selected="selected"]}
    end
    assert_select "input#place_x[value=?]",  "2900000"
    assert_select "input#place_y[value=?]",  "5400000"
    assert_select "input#place_altitude[value=?]",  "123"
end

test "edit many place as user" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    thisurl='xrv'+@testroute.id.to_s+'xpe'+@testplace.id.to_s
    viewurl='xrv'+@testroute.id.to_s+'xpv'+@testplace.id.to_s

    patch '/places/'+@testplace.id.to_s, place: { name: "A"*255, experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'

    assert_select "div#place_title2", "A"*255+" (Private Roadend)"
    assert_select "div#place_locn2", "NZTM2000: 1285319, 5097838 (alt: 4444m)"
    assert_select "div#fw_p2", "B"*3000
    assert_select "a[href=?]", '/routes/'+viewurl  #title shows cwe're on correct url

end

#edit someones elses place as user
test "view edit single place as not-creating-user" do
    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    thisurl='xpe'+@testplace.id.to_s
    viewurl='xpv'+@testplace.id.to_s

    patch '/places/'+@testplace.id.to_s, place: { name: "B"*255, experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "M"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl


    assert :success
    assert_template 'routes/show_many'

    assert_select "div#place_title1", "B"*255+" (Private Roadend)"
    assert_select "div#place_locn1", "NZTM2000: 1285319, 5097838 (alt: 4444m)"
    assert_select "div#fw_p1", "M"*3000
 
    #title shows view our place
    assert_select "a[href=?]", '/routes/'+viewurl  #title shows we're on correct url

end

#new single place as user
test "create single place as user" do
    #navigate to my route
    login_as(@testuser2.name,"password")
    assert is_logged_in?

    pc=Place.count

    post '/places/', place: { name: "C"*255, experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "M"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: 'xpn'

    assert :success
    assert_template 'routes/show_many'

    assert_select "a#place_link1", "C"*255+" (Private Roadend)"

    assert_equal Place.count, pc+1
    pl=Place.last
    assert_equal pl.name, "C"*255
    assert_equal pl.experienced_at.strftime("%F"), "2015-01-01"
    assert_equal pl.place_type, "Roadend"
    assert_equal pl.place_owner, "Private"
    assert_equal pl.description, "M"*3000
    #latlong updated from x,y
    assert_equal pl.location.x, 169.06155517285984
    assert_equal pl.location.y, -44.20475463476764
    assert_equal pl.projection_id, 27200
    assert_equal pl.x, 2195332.0
    assert_equal pl.y, 5659513.3
    assert_equal pl.altitude, 4444

    #no title  as endplace not valid
    #assert_select "a[href=?]", '/routes/xpb'+pl.id.to_s+'xps'

    #next action is select
    assert_select "div#actiontitle2", "Select next place on route:"
end

#edit invalid place
test "edit nonexistant place" do
    #navigate to my route
    login_as(@testuser.name,"password")
    assert is_logged_in?

    get '/routes/xpe999'
    assert :success
    assert_template 'routes/show_many'
    assert_select "input#place_name", false
    assert_select 'div#place_title1', false
end

  
# cannot edit as stranger, guest
test "cannot edit place as stranger" do
    get '/routes/xpe'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#place_title1', false
    assert_select "input#place_name", false

    #update as stranger
    tr=@testplace
    patch '/places/'+@testplace.id.to_s, place: { name: "B"*255, experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "M"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: 'xpe'+@testplace.id.to_s

    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#place_title1', false
    assert_select "input#place_name", false

    @testplace.reload
    assert_equal tr, @testplace


    #create as stranger
    rtcnt=Place.count

    post '/places/', place: { name: "C"*255, experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "M"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: 'xpe'+@testplace.id.to_s

    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#place_title1', false
    assert_select "input#place_name", false

    assert_equal rtcnt, Place.count

end

# cannot edit as stranger, guest
test "cannot edit place as guest" do
    add_place_to_trip(@testplace)
    assert is_guest?

    get '/routes/xpe'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#place_title1', false
    assert_select "input#place_name", false

    #update as stranger
    tr=@testplace
    patch '/places/'+@testplace.id.to_s, place: { name: "B"*255, experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "M"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: 'xpe'+@testplace.id.to_s

    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#place_title1', false
    assert_select "input#place_name", false

    @testplace.reload
    assert_equal tr, @testplace


    #create as stranger
    rtcnt=Place.count

    post '/places/', place: { name: "C"*255, experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "M"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: 'xpe'+@testplace.id.to_s

    assert :success
    assert_template 'routes/show_many'
    assert_select 'div#place_title1', false
    assert_select "input#place_name", false

    assert_equal rtcnt, Place.count
end

# handle parameter errors edit
test "handle mandatory parameter errors in edit place" do
    login_as(@testuser.name,"password")
    assert is_logged_in?

    #name
    thisurl='xpv'+@testplace2.id.to_s+'xrv'+@testroute.id.to_s+'xpe'+@testplace.id.to_s
    viewurl='xpv'+@testplace2.id.to_s+'xrv'+@testroute.id.to_s+'xpv'+@testplace.id.to_s

    patch '/places/'+@testplace.id.to_s, place: { name: "", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'

    #error
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name can&#39;t be blank"

    #display unchanged
    assert_select "input#place_name[value=?]",  ""
    assert_select "input#place_experienced_at[value=?]",  "2015-01-01"
    assert_select 'option[value="Roadend"]' do |t|
       assert_select %q{option[selected="selected"]}
    end
    assert_select "input#place_place_owner[value=?]",  "Private"
    assert_select "textarea#place_description",  "B"*3000
    assert_select 'option[value="27200"]' do |t|
       assert_select %q{option[selected="selected"]}
    end
    assert_select "input#place_x[value=?]",  "2195332.0"
    assert_select "input#place_y[value=?]",  "5659513.3"
    assert_select "input#place_altitude[value=?]",  "4444"
    
    @testplace.reload
    assert_equal @testplace.name, "testplace"
    assert_equal @testplace.experienced_at.strftime("%F"), "1900-01-01"
    assert_equal @testplace.place_type, "Hut"
    assert_equal @testplace.place_owner, "DOC"
    assert_equal @testplace.description, "test place1 description"
    #latlong updated from x,y
    assert_equal @testplace.location.x, 173
    assert_equal @testplace.location.y, -45
    assert_equal @testplace.projection_id,  2193
    assert_equal @testplace.x, 2900000
    assert_equal @testplace.y, 5400000
    assert_equal @testplace.altitude, 123

    #experienced_at
    #name
    patch '/places/'+@testplace.id.to_s, place: { name: "BBB", experienced_at: "", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'

    #error
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Experienced at can&#39;t be blank"

    #type
    patch '/places/'+@testplace.id.to_s, place: { name: "BBB", experienced_at: "2015-01-01", place_type: "", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save"

    assert :success
    assert_template 'routes/show_many'

    #error
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Place type can&#39;t be blank"


    #projection
    patch '/places/'+@testplace.id.to_s, place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'


    #error
    assert_select  "div.alert", "The form contains 2 errors."
    assert_select  "div#error_explanation>ul>li", "* Projection can&#39;t be blank"

    #x
    patch '/places/'+@testplace.id.to_s, place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'


    #error
    assert_select  "div.alert", "The form contains 2 errors."
    assert_select  "div#error_explanation>ul>li", "* Location can&#39;t be blank"

    #y
    patch '/places/'+@testplace.id.to_s, place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2722222", y: "", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'


    #error
    assert_select  "div.alert", "The form contains 2 errors."
    assert_select  "div#error_explanation>ul>li", "* Location can&#39;t be blank"


    #min fields allowed
    patch '/places/'+@testplace.id.to_s, place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "", description: "", location: "", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: ""}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'

    #success
    @testplace.reload
    assert_select  "div.alert", /Updated place, id:.*/
    assert_equal @testplace.name, "BBB"
    assert_equal @testplace.experienced_at.strftime("%F"), "2015-01-01"
    assert_equal @testplace.place_type, "Roadend"
    assert_equal @testplace.place_owner, ""
    assert_equal @testplace.description, ""
    #latlong updated from x,y
    assert_equal @testplace.location.x, 169.06155517285984
    assert_equal @testplace.location.y, -44.20475463476764
    assert_equal @testplace.projection_id, 27200
    assert_equal @testplace.x, 2195332.0
    assert_equal @testplace.y, 5659513.3
    assert_equal @testplace.altitude, 620 #calculated

end

# handle parameter errors new
test "handle mandatory parameter errors in new place" do
    login_as(@testuser.name,"password")
    assert is_logged_in?

    thisurl='xpv'+@testplace2.id.to_s+'xrv'+@testroute.id.to_s+'xpn'+@testplace.id.to_s
    viewurl='xpv'+@testplace2.id.to_s+'xrv'+@testroute.id.to_s+'xpb'+@testplace.id.to_s+'xps'


    pl=Place.count
    #name
    post '/places/', place: { name: "", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_equal pl, Place.count

    #error
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name can&#39;t be blank"

    #display unchanged
    assert_select "input#place_name[value=?]",  ""
    assert_select "input#place_experienced_at[value=?]",  "2015-01-01"
    assert_select 'option[value="Roadend"]' do |t|
       assert_select %q{option[selected="selected"]}
    end
    assert_select "input#place_place_owner[value=?]",  "Private"
    assert_select "textarea#place_description",  "B"*3000
    assert_select 'option[value="27200"]' do |t|
       assert_select %q{option[selected="selected"]}
    end
    assert_select "input#place_x[value=?]",  "2195332.0"
    assert_select "input#place_y[value=?]",  "5659513.3"
    assert_select "input#place_altitude[value=?]",  "4444"
    
    #experienced_at
    post '/places/', place: { name: "BBB", experienced_at: "", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_equal pl, Place.count

    #error
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Experienced at can&#39;t be blank"

    #type
    post '/places/', place: { name: "BBB", experienced_at: "2015-01-01", place_type: "", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_equal pl, Place.count

    #error
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Place type can&#39;t be blank"


    #projection
    post '/places/', place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "", x: "2195332.0", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_equal pl, Place.count


    #error
    assert_select  "div.alert", "The form contains 2 errors."
    assert_select  "div#error_explanation>ul>li", "* Projection can&#39;t be blank"

    #x
    post '/places/', place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "", y: "5659513.3", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_equal pl, Place.count


    #error
    assert_select  "div.alert", "The form contains 2 errors."
    assert_select  "div#error_explanation>ul>li", "* Location can&#39;t be blank"

    #y
    post '/places/', place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "Private", description: "B"*3000, location: "169.06157452349277 -44.20474889903012", projection_id: "27200", x: "2722222", y: "", altitude: "4444"}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_equal pl, Place.count


    #error
    assert_select  "div.alert", "The form contains 2 errors."
    assert_select  "div#error_explanation>ul>li", "* Location can&#39;t be blank"


    #min fields allowed
    post '/places/', place: { name: "BBB", experienced_at: "2015-01-01", place_type: "Roadend", place_owner: "", description: "", location: "", projection_id: "27200", x: "2195332.0", y: "5659513.3", altitude: ""}, save: "Save", url: thisurl

    assert :success
    assert_template 'routes/show_many'
    assert_equal pl+1, Place.count

    #success
    assert_select  "div.alert", /New place added, id:.*/    
    pl=Place.last
    assert_equal pl.name, "BBB"
    assert_equal pl.experienced_at.strftime("%F"), "2015-01-01"
    assert_equal pl.place_type, "Roadend"
    assert_equal pl.place_owner, ""
    assert_equal pl.description, ""
    #latlong updated from x,y
    assert_equal pl.location.x, 169.06155517285984
    assert_equal pl.location.y, -44.20475463476764
    assert_equal pl.projection_id, 27200
    assert_equal pl.x, 2195332.0
    assert_equal pl.y, 5659513.3
    assert_equal pl.altitude, 620

end
end


