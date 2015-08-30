require 'test_helper'

class RoutesViewTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

test "view single route as stranger" do
    #navigate to my route

    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'
    routetitle=@testroute.startplace.name+" to "+@testroute.endplace.name+" via "+@testroute.via 
    assert_select "div#route_title1", /#{@testroutetitle}.*/
    assert_select "span#route_dist1", "Distance: 1.0 km"
    assert_select "span#route_time1", "(3.0 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 300m to 400m.  Gain: 100m.  Loss: 0m"
    assert_select "span#route_grad1", ".  Gradient: 6 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Road.*/}
    assert_select "span#route_terr1", /.*Easy terrain.*/
    assert_select "span#gradien_smry1", /.*Flat.*/
    assert_select "span#alpines_smry1", ""
    assert_select "span#alpinew_smry1", ""
    assert_select "span#rivers_smry1", ""

    #detailed stats
    assert_select "span#type_text1", "Road"
    assert_select "span#impo_text1", "Primary, unmapped"
    assert_select "span#grad_text1", "Flat"
    assert_select "span#terr_text1", "Easy"
    assert_select "span#alps_text1", "None"
    assert_select "span#rive_text1", "None"
    assert_select "span#alpw_text1", "None"


    #main rouite details
    assert_select "div#gpx1", "GPX info source: drawn on map"
    assert_select "div#fw_r1", "A"*1000
    assert_select "span#rv_d1", "Z"*1000
    assert_select "div#fw_t1", "From "+@testroute.startplace.name+" to "+@testroute.endplace.name
    assert_select "div#rv_t1", "From "+@testroute.endplace.name+" to "+@testroute.startplace.name

    assert_select "div#links_section"

    assert_select "div#comments_section"

    #download gpx enabled
    assert_select "a[href=?]", '/routes/'+@testroute.id.to_s+'.gpx'+"?version="+@testroute.routeInstances.first.id.to_s

    #edit disabled
    assert_select  "span#editbutton", false
end

test "view many route as stranger" do
    #navigate to my route

    get '/routes/xrv'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'
    routetitle=@testroute.startplace.name+" to "+@testroute.endplace.name+" via "+@testroute.via
    assert_select "span#page_title", @testroute.startplace.name+" to "+@testroute.endplace.name

    #summary stats
    assert_select "span#agg_dist", "Distance: 1.0 km"
    assert_select "span#agg_time", "(3.0 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 300m to 400m.  Gain: 100m.  Loss: 0m"
    assert_select "span#agg_grad", ".  Gradient: 6 deg"
    assert_select "span#maxroutetype", /.*Road.*/
    assert_select "span#maxterrain", /.*Easy terrain.*/
    assert_select "span#maxgradient", /.*Flat.*/
    assert_select "span#maxalpines", ""
    assert_select "span#maxalpinew", ""
    assert_select "span#maxriver", ""

    #route1 stats
    assert_select "div#route_title1", /#{@testroutetitle}.*/
    assert_select "span#route_dist1", "Distance: 1.0 km"
    assert_select "span#route_time1", "(3.0 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 300m to 400m.  Gain: 100m.  Loss: 0m"
    assert_select "span#route_grad1", ".  Gradient: 6 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Road.*/}
    assert_select "span#route_terr1", /.*Easy terrain.*/
    assert_select "span#gradien_smry1", /.*Flat.*/
    assert_select "span#alpines_smry1", ""
    assert_select "span#alpinew_smry1", ""
    assert_select "span#rivers_smry1", ""

    #detailed stats
    assert_select "span#type_text1", "Road"
    assert_select "span#impo_text1", "Primary, unmapped"
    assert_select "span#grad_text1", "Flat"
    assert_select "span#terr_text1", "Easy"
    assert_select "span#alps_text1", "None"
    assert_select "span#rive_text1", "None"
    assert_select "span#alpw_text1", "None"

    #main rouite details
    assert_select "div#gpx1", "GPX info source: drawn on map"
    assert_select "div#fw_r1", "A"*1000
    assert_select "span#rv_d1", "Z"*1000
    assert_select "div#fw_t1", "From "+@testroute.startplace.name+" to "+@testroute.endplace.name
    assert_select "div#rv_t1", "From "+@testroute.endplace.name+" to "+@testroute.startplace.name

    assert_select "div#links_section",  false
    assert_select "div#comments_section", false

    #download gpx enabled
    assert_select "a[href=?]", '/routes/xrv'+@testroute.id.to_s+'.gpx'

    #edit disabled
    assert_select  "span#editbutton", false
end

#adjoining routes and neighbouring places
test "view adjoining routes and neighbouring places" do
   init_network()
 
   get '/routes/'+@rt2.id.to_s
   assert :success
   assert_template 'routes/show'
   #route joining to start
   assert_select "a#rs-"+@rt1.id.to_s
   assert_select "a#p"+@pl1.id.to_s
   assert_select "a#rs"+@rt2.id.to_s,false
   assert_select "a#rs-"+@rt2.id.to_s,false
   #route joining to end
   assert_select "a#rs"+@rt3.id.to_s
   assert_select "a#p"+@pl5.id.to_s
   assert_select "a#rs"+@rt4.id.to_s,false
   assert_select "a#rs"+@rt5.id.to_s,false
   assert_select "a#rs"+@rt6.id.to_s,false
   assert_select "a#rs-"+@rt4.id.to_s,false
   assert_select "a#rs-"+@rt5.id.to_s,false
   assert_select "a#rs-"+@rt6.id.to_s,false

   get '/routes/'+@rt11.id.to_s
   assert :success
   assert_template 'routes/show'
   #route joining to start link
   assert_select "a#rs-"+@rt10.id.to_s
   assert_select "a#p"+@pl10.id.to_s

   #route joining to end link
   assert_select "a#rs"+@rt12.id.to_s
   assert_select "a#p"+@pl15.id.to_s
   #route joining to intermediate place
   assert_select "a#rs"+@rt13.id.to_s
   assert_select "a#p"+@pl16.id.to_s
   assert_select "a#p"+@pl17.id.to_s

end

#adjoining places
test "view adjoining places to route" do

   init_network

   get '/routes/'+@rt2.id.to_s
   assert :success
   assert_template 'routes/show'
   #Hut when neighbur
   assert_select "a#p"+@pl1.id.to_s

   #Hut via intermediate
   assert_select "a#p"+@pl5.id.to_s

   #no non dest
   assert_select "a#p"+@pl4.id.to_s, false
   assert_select "a#p"+@pl6.id.to_s, false
   assert_select "a#p"+@pl7.id.to_s, false

   #not endpoints
   assert_select "a#p"+@pl2.id.to_s, false
   assert_select "a#p"+@pl3.id.to_s, false

   get '/routes/'+@rt4.id.to_s
   assert :success
   assert_template 'routes/show'

   #Dest 
   assert_select "a#p"+@pl3.id.to_s

   #Hut via dest
   assert_select "a#p"+@pl2.id.to_s

   #stub dest
   assert_select "a#p"+@pl7.id.to_s

   #No hut via hut
   assert_select "a#p"+@pl1.id.to_s, false

   assert_select "a#p"+@pl4.id.to_s, false
   assert_select "a#p"+@pl5.id.to_s, false
   assert_select "a#p"+@pl6.id.to_s, false
end

#trips passing through
test "view route lists trips using this route" do
     #reverse
    get '/routes/-'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

   assert_select "a#t"+@testtrip1.id.to_s          #forward route
   assert_select "a#t"+@testtrip4.id.to_s          #reverse route
   assert_select "a#t"+@testtrip2.id.to_s, false
   assert_select "a#t"+@testtrip3.id.to_s, false

    #forward
    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

   assert_select "a#t"+@testtrip1.id.to_s          #forward route
   assert_select "a#t"+@testtrip4.id.to_s          #reverse route
   assert_select "a#t"+@testtrip2.id.to_s, false
   assert_select "a#t"+@testtrip3.id.to_s, false

   #exclude draft trips
   @testtrip4.published=false
   @testtrip4.save

    get '/routes/-'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

   assert_select "a#t"+@testtrip1.id.to_s
   assert_select "a#t"+@testtrip4.id.to_s, false
end

#reverse
test "view single reverse route as stranger" do
    #navigate to my route

    get '/routes/-'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'
    routetitle=@testroute.endplace.name+" to "+@testroute.startplace.name+" via "+@testroute.via 
    assert_select "div#route_title1", /#{@testroutetitle}.*/
    assert_select "span#route_dist1", "Distance: 1.0 km"
    assert_select "span#route_time1", "(3.0 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 300m to 400m.  Gain: 0m.  Loss: 100m"
    assert_select "span#route_grad1", ".  Gradient: 6 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Road.*/}
    assert_select "span#route_terr1", /.*Easy terrain.*/
    assert_select "span#gradien_smry1", /.*Flat.*/
    assert_select "span#alpines_smry1", ""
    assert_select "span#alpinew_smry1", ""
    assert_select "span#rivers_smry1", ""

    #detailed stats
    assert_select "span#type_text1", "Road"
    assert_select "span#impo_text1", "Primary, unmapped"
    assert_select "span#grad_text1", "Flat"
    assert_select "span#terr_text1", "Easy"
    assert_select "span#alps_text1", "None"
    assert_select "span#rive_text1", "None"
    assert_select "span#alpw_text1", "None"


    #main rouite details
    assert_select "div#gpx1", "GPX info source: drawn on map"
    assert_select "div#fw_r1", "Z"*1000
    assert_select "span#rv_d1", "A"*1000
    assert_select "div#fw_t1", "From "+@testroute.endplace.name+" to "+@testroute.startplace.name
    assert_select "div#rv_t1", "From "+@testroute.startplace.name+" to "+@testroute.endplace.name

    assert_select "div#links_section"

    assert_select "div#comments_section"

    #download gpx enabled
    assert_select "a[href=?]", '/routes/-'+@testroute.id.to_s+'.gpx'+"?version="+@testroute.routeInstances.first.id.to_s

    #edit disabled
    assert_select  "span#editbutton", false
end

test "view many reverse route as stranger" do
    #navigate to my route

    get '/routes/xrv-'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'
    routetitle=@testroute.endplace.name+" to "+@testroute.startplace.name+" via "+@testroute.via
    assert_select "span#page_title", @testroute.endplace.name+" to "+@testroute.startplace.name

    #summary stats
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

    #route1 stats
    assert_select "div#route_title1", /#{@testroutetitle}.*/
    assert_select "span#route_dist1", "Distance: 1.0 km"
    assert_select "span#route_time1", "(3.0 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 300m to 400m.  Gain: 0m.  Loss: 100m"
    assert_select "span#route_grad1", ".  Gradient: 6 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Road.*/}
    assert_select "span#route_terr1", /.*Easy terrain.*/
    assert_select "span#gradien_smry1", /.*Flat.*/
    assert_select "span#alpines_smry1", ""
    assert_select "span#alpinew_smry1", ""
    assert_select "span#rivers_smry1", ""

    #detailed stats
    assert_select "span#type_text1", "Road"
    assert_select "span#impo_text1", "Primary, unmapped"
    assert_select "span#grad_text1", "Flat"
    assert_select "span#terr_text1", "Easy"
    assert_select "span#alps_text1", "None"
    assert_select "span#rive_text1", "None"
    assert_select "span#alpw_text1", "None"

    #main rouite details
    assert_select "div#gpx1", "GPX info source: drawn on map"
    assert_select "div#fw_r1", "Z"*1000
    assert_select "span#rv_d1", "A"*1000
    assert_select "div#fw_t1", "From "+@testroute.endplace.name+" to "+@testroute.startplace.name
    assert_select "div#rv_t1", "From "+@testroute.startplace.name+" to "+@testroute.endplace.name

    assert_select "div#links_section",  false

    assert_select "div#comments_section", false


    #download gpx enabled
    assert_select "a[href=?]", '/routes/xrv-'+@testroute.id.to_s+'.gpx'

    #edit disabled
    assert_select  "span#editbutton", false
end

#attribution
test "view route attribution" do
    #route with 1 version - single
    #no experience
    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")
    assert_select "div#updated", false
    
    #experience
    get '/routes/'+@testroute2.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")+". Experienced: 2015-01-01"
    assert_select "div#updated", false

    #route with 1 version - many
    get '/routes/xrv-'+@testroute2.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")+". Experienced: 2015-01-01"
    assert_select "div#updated", false

    #route with 2 versions - single
    sleep 1 #so temestamps differ
    @testroute.experienced_at="2014-02-02"
    @testroute.save
    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "div#versions"
    assert_select "div#created", false
    assert_select "div#updated", false

    

    #route with 2 versions - many
    get '/routes/xrv'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "div#versions", false
    assert_select "div#created", "Created by: Example user1 on "+Time.new().localtime().strftime("%F")
    assert_select "div#updated", "Last updated by: Example user1 at "+@testroute.updated_at.localtime().strftime("%F %T")+". Experienced: 2014-02-02"
end

#no descriptions
test "view routes with only one description" do
    @testroute.description=""
    @testroute.save

    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    #description reversed where no fw exists
    assert_select "span#rv_d1", "Z"*1000
    assert_select "div#fw_r1", "No description"
    assert_select "div#fw_r1[style='display:none']"
    assert_select "div#rv_r1[style='display:block']"

    get '/routes/-'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    #description reversed where no fw exists
    assert_select "span#rv_d1", "No description" 
    assert_select "div#fw_r1", "Z"*1000
    assert_select "div#fw_r1[style='display:block']"
    assert_select "div#rv_r1[style='display:none']"

 
    get '/routes/xrv'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    #description reversed where no fw exists
    assert_select "span#rv_d1", "Z"*1000
    assert_select "div#fw_r1", "No description"
    assert_select "div#fw_r1[style='display:none']"
    assert_select "div#rv_r1[style='display:block']"

    get '/routes/xrv-'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    #description reversed where no fw exists
    assert_select "span#rv_d1", "No description" 
    assert_select "div#fw_r1", "Z"*1000
    assert_select "div#fw_r1[style='display:block']"
    assert_select "div#rv_r1[style='display:none']"

end


#nulls

#edit vs ns
test "view route edit permissions" do
    #stranger
    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false
    assert_select "a#splitbutton", false

    get '/routes/xrv'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false
    assert_select "a#splitbutton", false

    #guest
    add_route_to_trip_rv(@testroute)
    assert is_guest?

    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false
    assert_select "a#splitbutton", false

    get '/routes/xrv'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "a#editbutton", false
    assert_select "span#edit1", false
    assert_select "a#splitbutton", false


    #user
    login_as(@testuser.name,"password")
    assert is_logged_in?
    get '/routes/'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show'

    assert_select "a#editbutton"
    assert_select "span#edit1", false
    assert_select "a#splitbutton"

    get '/routes/xrv'+@testroute.id.to_s
    assert :success
    assert_template 'routes/show_many'

    assert_select "a#editbutton"
    assert_select "span#edit1"
    assert_select "a#splitbutton", false


end

#view invalid route
test "view nonexistant route" do
    get '/routes/999'
    assert :success
    follow_redirect!
    assert_template 'routes/leg_index'

    get '/routes/-999'
    assert :success
    follow_redirect!
    assert_template 'routes/leg_index'

    get '/routes/x999'
    assert :success
    assert_template 'routes/show_many'
    assert_select "div#route_title1", false

    get '/routes/xrv999'
    assert :success
    assert_template 'routes/show_many'
    assert_select "div#route_title1", false
end

#partial routes
#xqv###y###y###
test "view partial route" do
    get 'routes/xqv'+@testroute.id.to_s+'y'+@testplace.id.to_s+'y'+@testplace2.id.to_s
    assert :success
    assert_template 'routes/show_many'

    routetitle=@testplace.name+" to "+@testplace2.name+" via "+@testroute.via
    assert_select "span#page_title", @testplace.name+" to "+@testplace2.name

    #summary stats
    assert_select "span#agg_dist", "Distance: 1.0 km"
    assert_select "span#agg_time", "(3.0 DOC hours)"
    assert_select "span#agg_alt", "Altitude: 300m to 400m.  Gain: 100m.  Loss: 0m"
    assert_select "span#agg_grad", ".  Gradient: 6 deg"
    assert_select "span#maxroutetype", /.*Road.*/
    assert_select "span#maxterrain", /.*Easy terrain.*/
    assert_select "span#maxgradient", /.*Flat.*/
    assert_select "span#maxalpines", ""
    assert_select "span#maxalpinew", ""
    assert_select "span#maxriver", ""

    #route1 stats
    assert_select "div#route_title1", /#{@testroutetitle}.*/
    assert_select "span#route_dist1", "Distance: 1.0 km"
    assert_select "span#route_time1", "(3.0 DOC hours)"
    assert_select "span#route_alti1", "Altitude: 300m to 400m.  Gain: 100m.  Loss: 0m"
    assert_select "span#route_grad1", ".  Gradient: 6 deg"
    assert_select "span#route_type1", {:count =>1, :text=> /.*Road.*/}
    assert_select "span#route_terr1", /.*Easy terrain.*/
    assert_select "span#gradien_smry1", /.*Flat.*/
    assert_select "span#alpines_smry1", ""
    assert_select "span#alpinew_smry1", ""
    assert_select "span#rivers_smry1", ""

    #detailed stats
    assert_select "span#type_text1", "Road"
    assert_select "span#impo_text1", "Primary, unmapped"
    assert_select "span#grad_text1", "Flat"
    assert_select "span#terr_text1", "Easy"
    assert_select "span#alps_text1", "None"
    assert_select "span#rive_text1", "None"
    assert_select "span#alpw_text1", "None"

    #main rouite details
    assert_select "div#gpx1", "GPX info source: drawn on map"
    assert_select "div#fw_r1", "A"*1000
    assert_select "span#rv_d1", "Z"*1000
    assert_select "div#fw_t1", "From "+@testroute.startplace.name+" to "+@testroute.endplace.name
    assert_select "div#rv_t1", "From "+@testroute.endplace.name+" to "+@testroute.startplace.name

    assert_select "div#links_section",  false
    assert_select "div#comments_section", false

    #download gpx enabled
    assert_select "a[href=?]", '/routes/xqv'+@testroute.id.to_s+'y'+@testplace.id.to_s+'y'+@testplace2.id.to_s+'.gpx'

    #e2e warning shown
    assert_select "p#e2ewarning"

    #r1 warnign shown
    assert_select "p#r1warning"

end

#gpx forward
test "view route forwards as gpx" do
    get '/routes/'+@testroute.id.to_s+'.gpx'

    reslat=[]
    reslon=[]

  #segment 1 - forward
    reslat[0]='-49.0'
    reslon[0]='175.0'
    reslat[1]='-49.0'
    reslon[1]='177.0'

    cnt=0
    tscnt=0
    #start of first to end of last
    assert_select "name", "testplacei3 to testplacei4 via track1"
    assert_select "trkseg", count:1  do |tts|
      tts.each do |tt|
        if tscnt==0  then
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

#gpx backwards
test "view route reverse as gpx" do
    get '/routes/-'+@testroute.id.to_s+'.gpx'

    reslat=[]
    reslon=[]

  #segment 1 - reverse
    reslat[0]='-49.0'
    reslon[0]='177.0'
    reslat[1]='-49.0'
    reslon[1]='175.0'

    cnt=0
    tscnt=0
    #start of first to end of last
    assert_select "name", "testplacei4 to testplacei3 via track1"
    assert_select "trkseg", count:1  do |tts|
      tts.each do |tt|
        if tscnt==0 then
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

#gpx many forward / reverse / partial
test "view route many as gpx" do
    get '/routes/xrv'+@testroute.id.to_s+'xpv'+@testplace.id.to_s+'xrv-'+@testroute.id.to_s+'xqv'+@testroute.id.to_s+'y'+@testplace.id.to_s+'y'+@testplace2.id.to_s+'xqv-'+@testroute.id.to_s+'y'+@testplace.id.to_s+'y'+@testplace2.id.to_s+'.gpx'

    reslat=[]
    reslon=[]

  #segment 1 - frwards
    reslat[0]='-49.0'
    reslon[0]='175.0'
    reslat[1]='-49.0'
    reslon[1]='177.0'

  #segment 2 - reverse
    reslat[2]='-49.0'
    reslon[2]='177.0'
    reslat[3]='-49.0'
    reslon[3]='175.0'

  #segment 3 - forwards
    reslat[4]='-49.0'
    reslon[4]='175.0'
    reslat[5]='-49.0'
    reslon[5]='177.0'

  #segment 4 - reverse
    reslat[6]='-49.0'
    reslon[6]='177.0'
    reslat[7]='-49.0'
    reslon[7]='175.0'

    cnt=0
    tscnt=0
    #start of first to end of last
    assert_select "name", "testplacei3 to testplacei3"
    assert_select "trkseg", count:4  do |tts|
      tts.each do |tt|
          assert_select tt, "trkpt", count:2  do |tps|
            tps.each do |tp|
              assert_select tp, 'trkpt[lat=?]',  reslat[cnt]
              assert_select tp, 'trkpt[lon=?]',  reslon[cnt]
             cnt+=1
            end
          end
        tscnt+=1
      end
    end
 end

end
