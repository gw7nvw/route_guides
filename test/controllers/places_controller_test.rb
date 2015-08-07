require 'test_helper'

class PlacesControllerTest < ActionController::TestCase

  def setup
    init()
  end

  ##########################################################################################
  #adjoiningRoutes tests
  #########################################################################################
  test "exclude route not associated with us" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl2,pl3)

    ars=pl1.adjoiningRoutesWithLinks()
    assert_equal ars.count, 0
  end  

  test "include route where we are start" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    rt1=create_route("rt1",pl1,pl2)

    ars=pl1.adjoiningRoutesWithLinks()
    assert_equal ars.count, 1
    assert_equal ars[0].id, rt1.id
  end

  test "include route where we are end" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    rt1=create_route("rt1",pl1,pl2)

    ars=pl2.adjoiningRoutesWithLinks()
    assert_equal ars.count, 1
    assert_equal ars[0].id, -rt1.id
  end

  test "include route from place linked to us" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl2,pl3)
    link_places(pl1, pl2)

    ars=pl1.adjoiningRoutesWithLinks()
    assert_equal ars.count, 1
    assert_equal ars[0].id, rt1.id
  end

  test "include route to place linked to us" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl3,pl2)
    link_places(pl1, pl2)

    ars=pl1.adjoiningRoutesWithLinks()
    assert_equal ars.count, 1
    assert_equal ars[0].id, -rt1.id
  end

  test "include route linked to us and allow both directions" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl2,pl3)
    link_place_to_route(pl1, rt1)

    ars=pl1.adjoiningRoutesWithLinks()
    assert_equal ars.count, 2
    assert_equal ars[0].id, rt1.id
    assert_equal ars[1].id, -rt1.id
  end

  test "include route linked to place linked to us and allow both directions" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl3,pl4)
    link_place_to_route(pl2, rt1)
    link_places(pl1, pl2)

    ars=pl1.adjoiningRoutesWithLinks()
    assert_equal ars.count, 2
    assert_equal ars[0].id, rt1.id
    assert_equal ars[1].id, -rt1.id
  end

  test "include route twice when it is linked to a place" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl1,pl2)
    link_place_to_route(pl3, rt1)

    ars=pl1.adjoiningRoutesWithLinks()
    assert_equal ars.count, 2
    assert_equal ars[0].id, rt1.id
    assert_equal ars[0].endplace_id, pl2.id
    assert_equal ars[1].id, rt1.id
    assert_equal ars[1].endplace_id, pl3.id
  end


  ########################################################################################
  #adjoiningPlaces tests
  ########################################################################################
  #neighbrouring huts = dest, direct
  test "forwards route" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    rt1=create_route("rt1",pl1,pl2)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 1
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
  end

  #backards route
  test "backwards route" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    rt1=create_route("rt1",pl1,pl2)

    aps=pl2.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 1
    assert_equal aps[0][:place], pl1.id
    assert_equal aps[0][:url], 'xrv-'+rt1.id.to_s
    assert_equal aps[0][:direct], true
  end

  #route linked to us
  test "route linked to us" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl2,pl3)
    link_place_to_route(pl1, rt1)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl3.id
    assert_equal aps[0][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl3.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl2.id
    assert_equal aps[1][:url], 'xqv-'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s
    assert_equal aps[1][:direct], true
  end

  #route to linked dest
  test "route to linked dest only lists main dest" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl1,pl2)
    link_places(pl2, pl3)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 1
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
  end

  #route with linked source
  test "route from linked source only appears once" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl1,pl2)
    link_places(pl1, pl3)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 1
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
  end

  #route linked to place linked to us
  test "route linked to place linked to us" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl3,pl4)
    link_places(pl1, pl2)
    link_place_to_route(pl2, rt1)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl4.id
    assert_equal aps[0][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl4.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xqv-'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl3.id.to_s
    assert_equal aps[1][:direct], true
  end

  #maxhops limit
  test "maxhops linits number of hops" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl2,pl3)

    aps=pl1.adjoiningPlaces(nil, false, 1, nil, nil)

    assert_equal aps.count, 1
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true

    aps=pl1.adjoiningPlaces(nil, false, 2, nil, nil)

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], false
  end

  #destonly
  test "destonly lists only direct places" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl2,pl3)
    rt3=create_route("rt3",pl3,pl4)

    #false - lists places whether or not direct
    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 3
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl4.id
    assert_equal aps[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s
    assert_equal aps[2][:direct], false

    #true lists only direct
    aps=pl1.adjoiningPlaces(nil, true, nil, nil, nil)
  
    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], true
  end

  #neighbouring destinations = direct
  test "hut as neighbour is direct" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    rt1=create_route("rt1",pl1,pl2)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 1
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
  end

  #hut via !dest = direct
  test "hut via !dest is direct" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl2,pl3)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], true
  end


  #hut via dest = direct
  test "hut via dest is direct" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl2,pl3)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], true
  end
  #hut via hut = !direct
  test "hut via hut is !direct" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl2,pl3)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], false
  end


#    3
#  /   \
# 1 --- 2 --- 4
  #no retrace same path
  test "do not retrace same path" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    rt4=create_route("rt4",pl2,pl4)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

    assert_equal aps.count, 6
    assert_equal aps[0][:place], pl3.id
    assert_equal aps[0][:url], 'xrv'+rt2.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl2.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl2.id
    assert_equal aps[2][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s
    assert_equal aps[2][:direct], true
    assert_equal aps[3][:place], pl4.id
    assert_equal aps[3][:url], 'xrv'+rt1.id.to_s+'xrv'+rt4.id.to_s
    assert_equal aps[3][:direct], true
    assert_equal aps[4][:place], pl3.id
    assert_equal aps[4][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s
    assert_equal aps[4][:direct], true
    assert_equal aps[5][:place], pl4.id
    assert_equal aps[5][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s
    assert_equal aps[5][:direct], true
  end

#    3
#  /   \
# 1 --- 2 --- 4
  #no revisit startplace
  test "do not revisit same place" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    rt4=create_route("rt4",pl2,pl4)


    aps=pl2.adjoiningPlaces(nil, false, nil, nil, nil)
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 5
    assert_equal aps[2][:place], pl1.id
    assert_equal aps[2][:url], 'xrv-'+rt1.id.to_s
    assert_equal aps[2][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv-'+rt3.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[0][:place], pl4.id
    assert_equal aps[0][:url], 'xrv'+rt4.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[3][:place], pl1.id
    assert_equal aps[3][:url], 'xrv-'+rt3.id.to_s+"xrv-"+rt2.id.to_s
    assert_equal aps[3][:direct], true
    assert_equal aps[4][:place], pl3.id
    assert_equal aps[4][:url], 'xrv-'+rt1.id.to_s+"xrv"+rt2.id.to_s
    assert_equal aps[4][:direct], false
  end

  #start at mid-point of segment
#    3
#  /   \2
# 1 --------- 4
#       
  test "routes from mid-point of a segment" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)

    aps=pl2.adjoiningPlaces(nil, false, nil, nil, nil)

#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 6
    assert_equal aps[0][:place], pl3.id
    assert_equal aps[0][:url], 'xrv-'+rt3.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl4.id
    assert_equal aps[1][:url], 'xqv'+rt1.id.to_s+"y"+pl2.id.to_s+"y"+pl4.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl1.id
    assert_equal aps[2][:url], 'xqv-'+rt1.id.to_s+"y"+pl2.id.to_s+"y"+pl1.id.to_s
    assert_equal aps[2][:direct], true
    assert_equal aps[3][:place], pl1.id
    assert_equal aps[3][:url], 'xrv-'+rt3.id.to_s+"xrv-"+rt2.id.to_s
    assert_equal aps[3][:direct], true
    assert_equal aps[4][:place], pl3.id
    assert_equal aps[4][:url], 'xqv-'+rt1.id.to_s+"y"+pl2.id.to_s+"y"+pl1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[4][:direct], false
    assert_equal aps[5][:place], pl4.id
    assert_equal aps[5][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+'xrv'+rt1.id.to_s
    assert_equal aps[5][:direct], false


  end
#    3
#  /   \2
# 1 --------- 4
#       
  test "routes from start-point of a segment" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)

   # Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
   # Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
   # aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 6
    assert_equal aps[0][:place], pl3.id
    assert_equal aps[0][:url], 'xrv'+rt2.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl4.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl2.id
    assert_equal aps[2][:url], 'xqv'+rt1.id.to_s+"y"+pl1.id.to_s+"y"+pl2.id.to_s
    assert_equal aps[2][:direct], true
    assert_equal aps[3][:place], pl2.id
    assert_equal aps[3][:url], 'xrv'+rt2.id.to_s+"xrv"+rt3.id.to_s
    assert_equal aps[3][:direct], true
    assert_equal aps[4][:place], pl3.id
    assert_equal aps[4][:url], 'xqv'+rt1.id.to_s+"y"+pl1.id.to_s+"y"+pl2.id.to_s+"xrv-"+rt3.id.to_s
    assert_equal aps[4][:direct], false
    assert_equal aps[5][:place], pl4.id
    assert_equal aps[5][:url], 'xrv'+rt2.id.to_s+"xrv"+rt3.id.to_s+'xqv'+rt1.id.to_s+"y"+pl2.id.to_s+"y"+pl4.id.to_s
    assert_equal aps[5][:direct], false
  end

  #do not revisit linked place to route
#    3
#  /   \2
# 1 --------- 4
#       
  test "routes from end-point of a segment" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)

    aps=pl4.adjoiningPlaces(nil, false, nil, nil, nil)

#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 6
    assert_equal aps[0][:place], pl1.id
    assert_equal aps[0][:url], 'xrv-'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl2.id
    assert_equal aps[1][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl3.id
    assert_equal aps[2][:url], 'xrv-'+rt1.id.to_s+"xrv"+rt2.id.to_s
    assert_equal aps[2][:direct], false
    assert_equal aps[3][:place], pl3.id
    assert_equal aps[3][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+'xrv-'+rt3.id.to_s
    assert_equal aps[3][:direct], false
    assert_equal aps[4][:place], pl2.id
    assert_equal aps[4][:url], 'xrv-'+rt1.id.to_s+"xrv"+rt2.id.to_s+"xrv"+rt3.id.to_s
    assert_equal aps[4][:direct], false
    assert_equal aps[5][:place], pl1.id
    assert_equal aps[5][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s
    assert_equal aps[5][:direct], false

end

  #base path with loops to start
#    3
#  /   \
# 1 --- 2 --- 4
  #no revisit startplace
  test "base path with loop to start" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    rt4=create_route("rt4",pl2,pl4)


    aps=pl1.adjoiningPlaces(nil, false, nil, {url: 'xrv'+rt1.id.to_s}, nil)
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 3
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl4.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt4.id.to_s
    assert_equal aps[1][:direct], false
    assert_equal aps[2][:place], pl3.id
    assert_equal aps[2][:url], 'xrv'+rt1.id.to_s+"xrv-"+rt3.id.to_s
    assert_equal aps[2][:direct], false

end

  #base path with loops to end
#    3
#  /   \
# 1 --- 2 --- 4
  test "base path with loop to end" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    rt4=create_route("rt4",pl2,pl4)


    aps=pl4.adjoiningPlaces(nil, false, nil, {url: 'xrv-'+rt4.id.to_s}, nil)
    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 5
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv-'+rt4.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl1.id
    assert_equal aps[2][:url], 'xrv-'+rt4.id.to_s+"xrv-"+rt1.id.to_s
    assert_equal aps[2][:direct], true
    assert_equal aps[3][:place], pl1.id
    assert_equal aps[3][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s
    assert_equal aps[3][:direct], true
    assert_equal aps[4][:place], pl3.id
    assert_equal aps[4][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[4][:direct], false
    
end 

  #base path with loops to start
#    3
#  /   \
# 1 --- 2 --- 4
  #no revisit startplace
  test "base path with loop to middle" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    rt4=create_route("rt4",pl2,pl4)


    aps=pl4.adjoiningPlaces(nil, false, nil, {url: 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s}, nil)
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl1.id
    assert_equal aps[0][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], false
end

  #base path with loops to start
#    3
#  /   \2
# 1 --------- 4
  #no revisit startplace
  test "base path with loop to linked place" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)


    aps=pl4.adjoiningPlaces(nil, false, nil, {url: 'xrv-'+rt1.id.to_s}, nil)
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 3
    assert_equal aps[0][:place], pl1.id
    assert_equal aps[0][:url], 'xrv-'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv-'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], false
    assert_equal aps[2][:place], pl2.id
    assert_equal aps[2][:url], 'xrv-'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s
    assert_equal aps[2][:direct], false
end

#    3
#  /   \2
# 1 --------- 4
  #no revisit startplace
  test "base partial path with loop to linked place" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)

    aps=pl4.adjoiningPlaces(nil, false, nil, {url: 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s}, nil)
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 3
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+'xrv-'+rt3.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl1.id
    assert_equal aps[2][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s
    assert_equal aps[2][:direct], true
end

#    3
#  /   \2
# 1 --------- 4
  #no revisit startplace
  test "base partial path with loop to start place" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)

    aps=pl2.adjoiningPlaces(nil, false, nil, {url: 'xqv-'+rt1.id.to_s+"y"+pl2.id.to_s+"y"+pl1.id.to_s}, nil)
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl1.id
    assert_equal aps[0][:url], 'xqv-'+rt1.id.to_s+"y"+pl2.id.to_s+"y"+pl1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xqv-'+rt1.id.to_s+"y"+pl2.id.to_s+"y"+pl1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], false
end

#    3
#  /   \2
# 1 --------- 4
  test "base partial path with loop to inerrmediate place" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)

    aps=pl4.adjoiningPlaces(nil, false, nil, {url: 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+'xrv-'+rt3.id.to_s}, nil)
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl3.id
    assert_equal aps[0][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+'xrv-'+rt3.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl1.id
    assert_equal aps[1][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s
    assert_equal aps[1][:direct], true
end


  #via place with link to a hut
  #base path with loops to end
#       3
# 1 --- 2 --- 4
  test "via place linked to a hut not direct" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl2,pl4)
    link_places(pl2, pl3)

    aps=pl1.adjoiningPlaces(nil, false, nil, nil, nil)
    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl4.id
    assert_equal aps[1][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], false #false due to linked place
end

#    3
#  /   \25
# 1 --------- 4
#       
  test "routes via linked place linked to a hut" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    rt1=create_route("rt1",pl1,pl4)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    link_place_to_route(pl2, rt1)
    link_places(pl2, pl5)

    aps=pl4.adjoiningPlaces(nil, false, nil, nil, nil)

   # Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
   # Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
   # aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 6
    assert_equal aps[0][:place], pl1.id
    assert_equal aps[0][:url], 'xrv-'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl2.id
    assert_equal aps[1][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s
    assert_equal aps[1][:direct], true
    assert_equal aps[2][:place], pl3.id
    assert_equal aps[2][:url], 'xrv-'+rt1.id.to_s+"xrv"+rt2.id.to_s
    assert_equal aps[2][:direct], false
    assert_equal aps[3][:place], pl3.id
    assert_equal aps[3][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+"xrv-"+rt3.id.to_s
    assert_equal aps[3][:direct], false #note - false due to linked place
    assert_equal aps[4][:place], pl2.id
    assert_equal aps[4][:url], 'xrv-'+rt1.id.to_s+"xrv"+rt2.id.to_s+'xrv'+rt3.id.to_s
    assert_equal aps[4][:direct], false
    assert_equal aps[5][:place], pl1.id
    assert_equal aps[5][:url], 'xqv-'+rt1.id.to_s+"y"+pl4.id.to_s+"y"+pl2.id.to_s+"xrv-"+rt3.id.to_s+"xrv-"+rt2.id.to_s
    assert_equal aps[5][:direct], false
  end

#    3
#  /   \
# 1 --- 2 --- 4
#       |
#       5

  test "dont revist basepath place" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    rt4=create_route("rt4",pl2,pl4)
    rt5=create_route("rt5",pl2,pl5)


    aps=pl4.adjoiningPlaces(nil, false, nil, {url: 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s}, nil)
    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 2
    assert_equal aps[0][:place], pl1.id
    assert_equal aps[0][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal aps[0][:direct], true
    assert_equal aps[1][:place], pl3.id
    assert_equal aps[1][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal aps[1][:direct], false

end

#    3
#  x   \
# 1 --- 2 --- 4
  test "dont use exclude path or its endpoints" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Roadend")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt1",pl1,pl2)
    rt2=create_route("rt2",pl1,pl3)
    rt3=create_route("rt3",pl3,pl2)
    rt4=create_route("rt4",pl2,pl4)

    aps=pl4.adjoiningPlaces(nil, false, nil, nil, rt2.id)
    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #aps.each do |ap| puts ap[:place].to_s+" : "+ap[:url] end

    assert_equal aps.count, 1
    assert_equal aps[0][:place], pl2.id
    assert_equal aps[0][:url], 'xrv-'+rt4.id.to_s
    assert_equal aps[0][:direct], true
    
end 

end
