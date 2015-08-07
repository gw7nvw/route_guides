							   require 'test_helper'

class RoutesControllerTest < ActionController::TestCase

  def setup
    @skiproutes=true
    init()
  end

######################################################################
#adjoiningRoutest tests

#routes where we start

#routes where we end

#routes at place linked to us

#routes at place linked to place linked to us

#do not include duplicates, self

######################################################################
#regenerateRouteIndex tests

#network 1
#
# 1 -- 2 -- 3
#      |    |
#      4 -- 5 -- 6

#regenerate routes individually
test "regenerate rt12" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt12",pl1,pl2)
    rt2=create_route("rt23",pl2,pl3)
    rt3=create_route("rt24",pl2,pl4)
    rt4=create_route("rt35",pl3,pl5)
    rt5=create_route("rt45",pl4,pl5)
    rt6=create_route("rt56",pl5,pl6)

    rt1.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}

    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0][:url], 'xrv'+rt1.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[5][:url], 'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt1.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+''
 assert_equal ris[7][:url], 'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[8][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[9][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[10][:url], 'xrv'+rt1.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[11][:url], 'xrv-'+rt6.id.to_s+'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[12][:url], 'xrv'+rt1.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+'xrv-'+rt4.id.to_s+''
 assert_equal ris[13][:url], 'xrv'+rt4.id.to_s+'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[14][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[15][:url], 'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[16][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv-'+rt5.id.to_s+''
 assert_equal ris[17][:url], 'xrv'+rt5.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''

end

# 1 -- 2 -- 3
#      |    |
#      4 -- 5 -- 6

test "regenerate rt23" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt12",pl1,pl2)
    rt2=create_route("rt23",pl2,pl3)
    rt3=create_route("rt24",pl2,pl4)
    rt4=create_route("rt35",pl3,pl5)
    rt5=create_route("rt45",pl4,pl5)
    rt6=create_route("rt56",pl5,pl6)

    rt2.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}

 #   Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0].url, 'xrv'+rt2.id.to_s+''
 assert_equal ris[1].url, 'xrv-'+rt2.id.to_s+''
 assert_equal ris[2].url, 'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[3].url, 'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[4].url, 'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[5].url, 'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[6].url, 'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv-'+rt5.id.to_s+''
 assert_equal ris[7].url, 'xrv'+rt5.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[8].url, 'xrv-'+rt3.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[9].url, 'xrv-'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[10].url, 'xrv-'+rt3.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[11].url, 'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[12].url, 'xrv-'+rt3.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[13].url, 'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[14].url, 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[15].url, 'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[16].url, 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[17].url, 'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[18].url, 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[19].url, 'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[20].url, 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv-'+rt5.id.to_s+''
 assert_equal ris[21].url, 'xrv'+rt5.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[22].url, 'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[23].url, 'xrv-'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+''
 assert_equal ris[24].url, 'xrv-'+rt6.id.to_s+'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[25].url, 'xrv-'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+'xrv'+rt6.id.to_s+''
end

# 1 -- 2 -- 3
#      |    |
#      4 -- 5 -- 6

test "regenerate rt56" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt12",pl1,pl2)
    rt2=create_route("rt23",pl2,pl3)
    rt3=create_route("rt24",pl2,pl4)
    rt4=create_route("rt35",pl3,pl5)
    rt5=create_route("rt45",pl4,pl5)
    rt6=create_route("rt56",pl5,pl6)

    rt6.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}

    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0][:url],  'xrv'+rt6.id.to_s+''
 assert_equal ris[1][:url],  'xrv-'+rt6.id.to_s+''
 assert_equal ris[2][:url],  'xrv'+rt5.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[3][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt5.id.to_s+''
 assert_equal ris[4][:url],  'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[5][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+''
 assert_equal ris[6][:url],  'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[7][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+''
 assert_equal ris[8][:url],  'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[9][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[10][:url],  'xrv-'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[11][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[12][:url],  'xrv'+rt1.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt5.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[13][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[14][:url],  'xrv-'+rt3.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[15][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[16][:url],  'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[17][:url],  'xrv-'+rt6.id.to_s+'xrv-'+rt4.id.to_s+'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''

end


#       --- 3
#      2    |
# 1-------- 4 -- 5

test "regenerate linked route 45" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    rt1=create_route("rt14",pl1,pl4)
    rt2=create_route("rt23",pl2,pl3)
    rt3=create_route("rt34",pl3,pl4)
    rt4=create_route("rt45",pl4,pl5)
    link_place_to_route(pl2, rt1)

    rt4.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}

    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0][:url], 'xrv'+rt4.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt4.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt1.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[5][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[6][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[7][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s
 assert_equal ris[8][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[9][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[10][:url], 'xrv-'+rt2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[11][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[12][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[13][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s

end

#       --- 3
#      2    |
# 1-------- 4 -- 5

test "regenerate linked route 23" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    rt1=create_route("rt14",pl1,pl4)
    rt2=create_route("rt23",pl2,pl3)
    rt3=create_route("rt34",pl3,pl4)
    rt4=create_route("rt45",pl4,pl5)
    link_place_to_route(pl2, rt1)

    rt2.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}

 #   Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end
 assert_equal ris[0][:url], 'xrv'+rt2.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt2.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[5][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[7][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[8][:url], 'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[9][:url], 'xrv-'+rt2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s
 assert_equal ris[10][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[11][:url], 'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s
 assert_equal ris[12][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[13][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s
 assert_equal ris[14][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[15][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s
 assert_equal ris[16][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[17][:url], 'xrv-'+rt2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt4.id.to_s+''

end

#linked 14
#       --- 3
#      2    |
# 1-------- 4 -- 5

test "regenerate linked route 14" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    rt1=create_route("rt14",pl1,pl4)
    rt2=create_route("rt23",pl2,pl3)
    rt3=create_route("rt34",pl3,pl4)
    rt4=create_route("rt45",pl4,pl5)
    link_place_to_route(pl2, rt1)

    rt1.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}

#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end
 assert_equal ris[0][:url], 'xrv'+rt1.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+''
 assert_equal ris[5][:url], 'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[7][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[8][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s
 assert_equal ris[9][:url], 'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s
 assert_equal ris[10][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[11][:url], 'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[12][:url], 'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[13][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[14][:url], 'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[15][:url], 'xrv-'+rt2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[16][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[17][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[18][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[19][:url], 'xrv-'+rt2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[20][:url], 'xrv'+rt3.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[21][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv-'+rt3.id.to_s+''

end

#  1      4
#  | \  / |
#  |  25  |
#  | /  \ |
#  3      6
test "regenerate route with linked endpoint to endpoint" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt14",pl1,pl2)
    rt2=create_route("rt23",pl2,pl3)
    rt3=create_route("rt13",pl1,pl3)
    rt4=create_route("rt45",pl4,pl5)
    rt5=create_route("rt56",pl5,pl6)
    rt6=create_route("rt46",pl4,pl6)
    link_places(pl2, pl5)

    rt1.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}
#    Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
#    ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 ###NB: we shouldn;t really be using xqv for linked endpoints as the __whole_ route
 # is used and xqv will flag the route as partial.  However the additional code 
 # required to change this looks unjustified
 assert_equal ris[0][:url], 'xrv'+rt1.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt1.id.to_s+'xqv'+rt5.id.to_s+'y'+pl2.id.to_s+'y'+pl6.id.to_s+''
 assert_equal ris[5][:url], 'xqv-'+rt5.id.to_s+'y'+pl6.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt1.id.to_s+'xqv-'+rt4.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[7][:url], 'xqv'+rt4.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[8][:url], 'xrv'+rt1.id.to_s+'xqv'+rt5.id.to_s+'y'+pl2.id.to_s+'y'+pl6.id.to_s+'xrv-'+rt6.id.to_s+''
 assert_equal ris[9][:url], 'xrv'+rt6.id.to_s+'xqv-'+rt5.id.to_s+'y'+pl6.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[10][:url], 'xrv'+rt1.id.to_s+'xqv-'+rt4.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[11][:url], 'xrv-'+rt6.id.to_s+'xqv'+rt4.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[12][:url], 'xrv-'+rt3.id.to_s+'xrv'+rt1.id.to_s+''
 assert_equal ris[13][:url], 'xrv-'+rt1.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[14][:url], 'xrv-'+rt3.id.to_s+'xrv'+rt1.id.to_s+'xqv'+rt5.id.to_s+'y'+pl2.id.to_s+'y'+pl6.id.to_s+''
 assert_equal ris[15][:url], 'xqv-'+rt5.id.to_s+'y'+pl6.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[16][:url], 'xrv-'+rt3.id.to_s+'xrv'+rt1.id.to_s+'xqv-'+rt4.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[17][:url], 'xqv'+rt4.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[18][:url], 'xrv-'+rt3.id.to_s+'xrv'+rt1.id.to_s+'xqv'+rt5.id.to_s+'y'+pl2.id.to_s+'y'+pl6.id.to_s+'xrv-'+rt6.id.to_s+''
 assert_equal ris[19][:url], 'xrv'+rt6.id.to_s+'xqv-'+rt5.id.to_s+'y'+pl6.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[20][:url], 'xrv-'+rt3.id.to_s+'xrv'+rt1.id.to_s+'xqv-'+rt4.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt6.id.to_s+''
 assert_equal ris[21][:url], 'xrv-'+rt6.id.to_s+'xqv'+rt4.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s+'xrv'+rt3.id.to_s+''

end


#linked 15
#      3--- 4
#      2    |
# 1-------- 5 -- 6
test "regenerate route with linked midpoint linked to endpoint" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt15",pl1,pl5)
    rt2=create_route("rt34",pl3,pl4)
    rt3=create_route("rt45",pl4,pl5)
    rt4=create_route("rt56",pl5,pl6)
    link_place_to_route(pl2, rt1)
    link_places(pl2, pl3)

    rt1.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}
 #   Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0][:url], 'xrv'+rt1.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+''
 assert_equal ris[5][:url], 'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[7][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[8][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[9][:url], 'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[10][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[11][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[12][:url], 'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[13][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+''
 assert_equal ris[14][:url], 'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[15][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+''
 assert_equal ris[16][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[17][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[18][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[19][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[20][:url], 'xrv'+rt3.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[21][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv-'+rt3.id.to_s+''

# also get:  xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+' but shouldn't
# also get:  xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+' but shouldn't

end

#linked 34
#      3--- 4
#      2    |
# 1-------- 5 -- 6

test "regenerate route with linked endpoint linked to midpoint" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt15",pl1,pl5)
    rt2=create_route("rt34",pl3,pl4)
    rt3=create_route("rt45",pl4,pl5)
    rt4=create_route("rt56",pl5,pl6)
    link_place_to_route(pl2, rt1)
    link_places(pl2, pl3)

    rt2.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}
    #Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
    #ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0][:url], 'xrv'+rt2.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt2.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[5][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[7][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
# bad assert_equal ris[8][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+''
# bad assert_equal ris[9][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[10][:url], 'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl3.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[11][:url], 'xrv-'+rt2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl3.id.to_s+'y'+pl5.id.to_s+''
 assert_equal ris[12][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl3.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[13][:url], 'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl3.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[14][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl3.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[15][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl3.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[16][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl3.id.to_s+'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[17][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl3.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[18][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl3.id.to_s+'xrv'+rt2.id.to_s+''
 assert_equal ris[19][:url], 'xrv-'+rt2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl3.id.to_s+'y'+pl5.id.to_s+'xrv'+rt4.id.to_s+''

end
#linked 34
# 3-------- 4
#      2    |
# 1-------- 5 -- 6
test "regenerate route with linked midpoint linked to route" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt15",pl1,pl5)
    rt2=create_route("rt34",pl3,pl4)
    rt3=create_route("rt45",pl4,pl5)
    rt4=create_route("rt56",pl5,pl6)
    link_place_to_route(pl2, rt1)
    link_place_to_route(pl2, rt2)

    rt2.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}
 #   Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0][:url], 'xrv'+rt2.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt2.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[5][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[7][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[8][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[9][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[10][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[11][:url], 'xqv-'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[12][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+''
 assert_equal ris[13][:url], 'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[14][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[15][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[16][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[17][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[18][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[19][:url], 'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[20][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+''
 assert_equal ris[21][:url], 'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[22][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[23][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[24][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[25][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[26][:url], 'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[27][:url], 'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[28][:url], 'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[29][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[30][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[31][:url], 'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[32][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[33][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl2.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[34][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[35][:url], 'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''

end

#linked 34
# 3-------- 4
#      7    |
#      2    |
# 1-------- 5 -- 6
test "regenerate route with linked midpoint linked to linked midpoint" do
    pl1=create_place("pl1","Hut")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    pl7=create_place("pl7","Hut")
    rt1=create_route("rt15",pl1,pl5)
    rt2=create_route("rt34",pl3,pl4)
    rt3=create_route("rt45",pl4,pl5)
    rt4=create_route("rt56",pl5,pl6)
    link_place_to_route(pl2, rt1)
    link_place_to_route(pl7, rt2)
    link_places(pl2,pl7)

    rt2.regenerate_route_index()

    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}
 #   Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   ris.each do |ri| puts ri[:place].to_s+" : "+ri[:url] end

 assert_equal ris[0][:url], 'xrv'+rt2.id.to_s+''
 assert_equal ris[1][:url], 'xrv-'+rt2.id.to_s+''
 assert_equal ris[2][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[3][:url], 'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[4][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[5][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[6][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
 assert_equal ris[7][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[8][:url], 'xrv'+rt2.id.to_s+'xrv'+rt3.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+''
 assert_equal ris[9][:url], 'xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv-'+rt3.id.to_s+'xrv-'+rt2.id.to_s+''
 assert_equal ris[10][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl7.id.to_s+''
 assert_equal ris[11][:url], 'xqv-'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[12][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl7.id.to_s+'xqv'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl5.id.to_s+''
 assert_equal ris[13][:url], 'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl7.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[14][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl7.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[15][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl7.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[16][:url], 'xqv'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl7.id.to_s+'xqv'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl5.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[17][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl7.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl3.id.to_s+''
 assert_equal ris[18][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+''
 assert_equal ris[19][:url], 'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[20][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+'xqv'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl5.id.to_s+''
 assert_equal ris[21][:url], 'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl7.id.to_s+'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[22][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[23][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl7.id.to_s+'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[24][:url], 'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+'xqv'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl5.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[25][:url], 'xrv-'+rt4.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl7.id.to_s+'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+''
 assert_equal ris[26][:url], 'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+''
 assert_equal ris[27][:url], 'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[28][:url], 'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[29][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl7.id.to_s+'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+''
 assert_equal ris[30][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+''
 assert_equal ris[31][:url], 'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[32][:url], 'xrv-'+rt4.id.to_s+'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl7.id.to_s+'y'+pl1.id.to_s+''
 assert_equal ris[33][:url], 'xqv'+rt1.id.to_s+'y'+pl1.id.to_s+'y'+pl7.id.to_s+'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+'xrv'+rt4.id.to_s+''
 assert_equal ris[34][:url], 'xrv'+rt1.id.to_s+'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+''
 assert_equal ris[35][:url], 'xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+'xrv-'+rt1.id.to_s+''
# shouldn;t get this but do assert_equal ris[0][:url], xqv'+rt1.id.to_s+'y'+pl2.id.to_s+'y'+pl5.id.to_s+'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl4.id.to_s+'y'+pl7.id.to_s+'
# shouldn;t get this but do assert_equal ris[0][:url], xqv'+rt2.id.to_s+'y'+pl7.id.to_s+'y'+pl4.id.to_s+'xrv'+rt3.id.to_s+'xqv-'+rt1.id.to_s+'y'+pl5.id.to_s+'y'+pl2.id.to_s+'
end

# 1 --- 2 --- 3
test "hut as neighbour is direct, via hut is not direct" do
    pl1=create_place("pl1","Roadend")
    pl2=create_place("pl2","Hut")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt12",pl1,pl2)
    rt2=create_route("rt23",pl2,pl3)

    rt1.regenerate_route_index()
    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}
 #   Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   ris.each do |ri| puts ri[:place].to_s + ":" + ri[:url]+":"+ri.isdest.to_s+":"+ri.fromdest.to_s+":"+ri.direct.to_s end

    #direct
    assert_equal ris[0][:url], 'xrv'+rt1.id.to_s
    assert_equal ris[0][:fromdest], true
    assert_equal ris[0][:isdest], true
    assert_equal ris[0][:direct], true
    assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s
    assert_equal ris[1][:fromdest], true
    assert_equal ris[1][:isdest], true
    assert_equal ris[1][:direct], true
    #indirect
    assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal ris[2][:fromdest], true
    assert_equal ris[2][:isdest], true
    assert_equal ris[2][:direct], false
    assert_equal ris[3][:url], 'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal ris[3][:fromdest], true
    assert_equal ris[3][:isdest], true
    assert_equal ris[3][:direct], false
 
  end

# 1 --- 2 --- 3
test "hut via !dest is direct, !dest as stub is dest, !dest as !stub is !dest" do
    pl1=create_place("pl1","Junction")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Hut")
    rt1=create_route("rt12",pl1,pl2)
    rt2=create_route("rt23",pl2,pl3)

    rt1.regenerate_route_index()
    ris=RouteIndex.all.order(:id)#.sort_by{ |ri| ri[:url]}
 #   Place.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   Route.all.each do |pl| puts pl.id.to_s+" : "+pl.name end
 #   ris.each do |ri| puts ri[:place].to_s + ":" + ri[:url]+":"+ri.isdest.to_s+":"+ri.fromdest.to_s+":"+ri.direct.to_s end

    #direct
    assert_equal ris[0][:url], 'xrv'+rt1.id.to_s
    assert_equal ris[0][:fromdest], true
    assert_equal ris[0][:isdest], false
    assert_equal ris[0][:direct], true
    assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s
    assert_equal ris[1][:fromdest], false
    assert_equal ris[1][:isdest], true
    assert_equal ris[1][:direct], true
    #indirect
    assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal ris[2][:fromdest], true
    assert_equal ris[2][:isdest], true
    assert_equal ris[2][:direct], true
    assert_equal ris[3][:url], 'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal ris[3][:fromdest], true
    assert_equal ris[3][:isdest], true
    assert_equal ris[3][:direct], true
 
  end


#            
#       3          
# 1 --- 2 ------- 4
test "via place linked to a hut not direct" do
    pl1=create_place("pl1","Junction")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Hut")
    pl4=create_place("pl4","Hut")
    rt1=create_route("rt12",pl1,pl2)
    rt2=create_route("rt24",pl2,pl4)
    link_places(pl2,pl3)

    rt1.regenerate_route_index()
    ris=RouteIndex.all.order(:id)

    #    ris.each do |ri| puts ri[:place].to_s + ":" + ri[:url]+":"+ri.isdest.to_s+":"+ri.fromdest.to_s+":"+ri.direct.to_s end

    #direct
    assert_equal ris[0][:url], 'xrv'+rt1.id.to_s
    assert_equal ris[0][:fromdest], true
    assert_equal ris[0][:isdest], true
    assert_equal ris[0][:direct], true
    assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s
    assert_equal ris[1][:fromdest], true
    assert_equal ris[1][:isdest], true
    assert_equal ris[1][:direct], true
    #indirect
    assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal ris[2][:fromdest], true
    assert_equal ris[2][:isdest], true
    assert_equal ris[2][:direct], false
    assert_equal ris[3][:url], 'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal ris[3][:fromdest], true
    assert_equal ris[3][:isdest], true
    assert_equal ris[3][:direct], false

  end

#           6
#           3 --- 5
# 1 --- 2 ------- 4
test "routes via linked place linked to a hut" do
    pl1=create_place("pl1","Junction")
    pl2=create_place("pl2","Junction")
    pl3=create_place("pl3","Junction")
    pl4=create_place("pl4","Hut")
    pl5=create_place("pl5","Hut")
    pl6=create_place("pl6","Hut")
    rt1=create_route("rt12",pl1,pl2)
    rt2=create_route("rt24",pl2,pl4)
    rt3=create_route("rt35",pl3,pl5)
    link_places(pl3,pl6)
    link_place_to_route(pl3, rt2)

    rt1.regenerate_route_index()
    ris=RouteIndex.all.order(:id)

#    ris.each do |ri| puts ri[:place].to_s + ":" + ri[:url]+":"+ri.isdest.to_s+":"+ri.fromdest.to_s+":"+ri.direct.to_s end

    #direct
    assert_equal ris[0][:url], 'xrv'+rt1.id.to_s
    assert_equal ris[0][:fromdest], true
    assert_equal ris[0][:isdest], false
    assert_equal ris[0][:direct], true
    assert_equal ris[1][:url], 'xrv-'+rt1.id.to_s
    assert_equal ris[1][:fromdest], false
    assert_equal ris[1][:isdest], true
    assert_equal ris[1][:direct], true
    #indirect via jn
    assert_equal ris[2][:url], 'xrv'+rt1.id.to_s+'xrv'+rt2.id.to_s
    assert_equal ris[2][:fromdest], true
    assert_equal ris[2][:isdest], true
    assert_equal ris[2][:direct], true
    assert_equal ris[3][:url], 'xrv-'+rt2.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal ris[3][:fromdest], true
    assert_equal ris[3][:isdest], true
    assert_equal ris[3][:direct], true
    #indirect via jn to jn/hut (dest=true, direct=true)
    assert_equal ris[4][:url], 'xrv'+rt1.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl3.id.to_s
    assert_equal ris[4][:fromdest], true
    assert_equal ris[4][:isdest], true
    assert_equal ris[4][:direct], true
    assert_equal ris[5][:url], 'xqv-'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal ris[5][:fromdest], true
    assert_equal ris[5][:isdest], true
    assert_equal ris[5][:direct], true
    #indirect via jn/hut (dest=true, direct=false)
    assert_equal ris[6][:url], 'xrv'+rt1.id.to_s+'xqv'+rt2.id.to_s+'y'+pl2.id.to_s+'y'+pl3.id.to_s+'xrv'+rt3.id.to_s
    assert_equal ris[6][:fromdest], true
    assert_equal ris[6][:isdest], true
    assert_equal ris[6][:direct], false
    assert_equal ris[7][:url], 'xrv-'+rt3.id.to_s+'xqv-'+rt2.id.to_s+'y'+pl3.id.to_s+'y'+pl2.id.to_s+'xrv-'+rt1.id.to_s
    assert_equal ris[7][:fromdest], true
    assert_equal ris[7][:isdest], true
    assert_equal ris[7][:direct], false


  end

end
