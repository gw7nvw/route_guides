require 'test_helper'

class PlacesViewTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "view single place as stranger" do
    #navigate to place

    get '/places/'+@testplace.id.to_s
    assert :success
    assert_template 'places/show'

    assert_select "div#place_title1", "testplace (DOC Hut)"
    assert_select "div#place_locn1", "NZTM2000: 1600000, 5017050 (alt: 123m)" #from LINZ: should be 5017049.600, 16000000.000
    assert_select "div#fw_p1", "test place1 description"

    #no edit
    assert_select "span#Edit1", false

    #min fields
    get '/places/'+@testplace2.id.to_s
    assert :success
    assert_template 'places/show'

    #No owner
    assert_select "div#place_title1", "testplacei2 (Hut)"
    #No alt
    assert_select "div#place_locn1", "NZTM2000: 1600000, 4905953" #from LINZ: should be 1600000.000, 4905952.508
    #No description
    assert_select "div#fw_p1", ""

    #no edit
    assert_select "span#Edit1", false
end
test "view many place as stranger" do
    #navigate to place

    get '/routes/xpv'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "div#place_title1", "testplace (DOC Hut)"
    assert_select "div#place_locn1", "NZTM2000: 1600000, 5017050 (alt: 123m)" #from LINZ: should be 5017049.600, 16000000.000
    assert_select "div#fw_p1", "test place1 description"

    #no edit
    assert_select "span#Edit1", false

    #min fields
    get '/routes/xpv'+@testplace2.id.to_s
    assert :success
    assert_template 'routes/show_many'

    #No owner
    assert_select "div#place_title1", "testplacei2 (Hut)"
    #No alt
    assert_select "div#place_locn1", "NZTM2000: 1600000, 4905953" #from LINZ: should be 1600000.000, 4905952.508
    #No description
    assert_select "div#fw_p1", ""

    #no edit
    assert_select "span#Edit1", false

    #many places
    get '/routes/xpv'+@testplace2.id.to_s+'xrv'+@testroute.id.to_s+'xpv'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'
    assert_select 'span#page_title', 'testplacei2 to testplace'
    assert_select "div#place_title1", "testplacei2 (Hut)"
    assert_select "div#place_locn1", "NZTM2000: 1600000, 4905953" #from LINZ: should be 1600000.000, 4905952.508
    assert_select "div#fw_p1", ""
    assert_select "div#place_title3", "testplace (DOC Hut)"
    assert_select "div#place_locn3", "NZTM2000: 1600000, 5017050 (alt: 123m)" #from LINZ: should be 5017049.600, 16000000.000
    assert_select "div#fw_p3", "test place1 description"
end

test "view adjoining routes and neighbouring places" do
#adjoining routes and neighbouring places
   init_network()

   get '/places/'+@pl2.id.to_s
   assert :success
   assert_template 'places/show'
   #route joining to start
   assert_select "a#p"+@pl1.id.to_s

   #route joining to end
   assert_select "a#p"+@pl3.id.to_s
   assert_select "a#p"+@pl5.id.to_s
   assert_select "a#p"+@pl2.id.to_s, false
   assert_select "a#p"+@pl4.id.to_s, false
   assert_select "a#p"+@pl6.id.to_s, false
   assert_select "a#p"+@pl7.id.to_s, false

   get '/places/'+@pl11.id.to_s
   assert :success
   assert_template 'places/show'
   #route joining to start link
   assert_select "a#p"+@pl10.id.to_s
   assert_select "a#p"+@pl11.id.to_s, false
   assert_select "a#p"+@pl12.id.to_s, false
   #route joining to end link
   assert_select "a#p"+@pl13.id.to_s
   assert_select "a#p"+@pl14.id.to_s
   assert_select "a#p"+@pl15.id.to_s, false
   #route joining to intermediate place
   assert_select "a#p"+@pl16.id.to_s
   assert_select "a#p"+@pl17.id.to_s
end

test "view place lists trips using this place" do
   get '/places/'+@testplace2.id.to_s
   assert :success
   assert_template 'places/show'

   assert_select "a#t"+@testtrip1.id.to_s          #forward route
   assert_select "a#t"+@testtrip3.id.to_s          #reverse route
   assert_select "a#t"+@testtrip2.id.to_s, false
   assert_select "a#t"+@testtrip4.id.to_s, false

end

test "view place attribution" do
    sleep 2
    #route with 1 version - single
    #no experience
    get '/places/'+@testplace.id.to_s
    assert :success
    assert_template 'places/show'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")
    assert_equal @testplace.placeInstances.count, 1
    assert_select "div#updated", false

    #experience
    get '/places/'+@testplace2.id.to_s
    assert :success
    assert_template 'places/show'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")+". Experienced: 2015-01-01"
    assert_select "div#updated", false

    #route with 1 version - many
    get '/routes/xpv'+@testplace2.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")+". Experienced: 2015-01-01"
    assert_select "div#updated", false

    #route with 2 versions - single
    @testplace.experienced_at="2014-02-02"
    @testplace.save
    @testplace.create_new_instance
    get '/places/'+@testplace.id.to_s
    assert :success
    assert_template 'places/show'

    assert_select "div#versions"
    assert_select "div#created", false
    assert_select "div#updated", false

    #route with 2 versions - many
    get '/routes/xpv'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")
    assert_select "div#updated", "Last updated by: Example user1 at "+@testplace.updated_at.localtime().strftime("%F %T")+". Experienced: 2014-02-02"

end

test "view place edit permissions" do
    #stranger
    get '/places/'+@testplace.id.to_s
    assert :success
    assert_template 'places/show'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false

    get '/routes/xpv'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false

    #guest
    add_place_to_trip(@testplace)
    assert is_guest?

    get '/places/'+@testplace.id.to_s
    assert :success
    assert_template 'places/show'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false

    get '/routes/xpv'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false

    #user
    login_as(@testuser.name,"password")
    assert is_logged_in?
    get '/places/'+@testplace.id.to_s
    assert :success
    assert_template 'places/show'

    assert_select "a#editbutton"
    assert_select "span#edit1", false

    get '/routes/xpv'+@testplace.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "a#editbutton"
    assert_select "span#edit1"

end

test "view nonexistant place" do
    get '/places/999'
    assert :success
    follow_redirect!
    assert_template 'places/index'

    get '/routes/xpv999'
    assert :success
    assert_template 'routes/show_many'
    assert_select "div#place_title1", false

end

end
