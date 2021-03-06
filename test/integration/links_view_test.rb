require 'test_helper'

class LinksViewTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

  def createLinks(baseType, baseId)
    @l1=Link.create(item_id:@testplace.id, item_type: 'place', baseItem_id:baseId, baseItem_type: baseType, item_url: nil )
    @l2=Link.create(item_id:@testroute.id, item_type: 'route', baseItem_id:baseId, baseItem_type: baseType, item_url: nil )
    #@l3=Link.create(item_id:-@testroute.id, item_type: 'route', baseItem_id:baseId, baseItem_type: baseType, item_url: nil )
    @l4=Link.create(item_id:@testtrip1.id, item_type: 'trip', baseItem_id:baseId, baseItem_type: baseType, item_url: nil )
    @l5=Link.create(item_id:@teststory1.id, item_type: 'report', baseItem_id:baseId, baseItem_type: baseType, item_url: nil )
    @l6=Link.create(item_id:@testphoto1.id, item_type: 'photo', baseItem_id:baseId, baseItem_type: baseType, item_url: nil )
    @l7=Link.create(item_id:nil, item_type: 'URL', baseItem_id:baseId, baseItem_type: baseType, item_url: "http://stuff.nz/" )
    @l8=Link.create(item_id:nil, item_type: 'about', baseItem_id:baseId, baseItem_type: baseType, item_url: "http://routeguires.co.nz/users" )
  end


test "view links on places page as stranger" do

  createLinks('place', @testplace2.id)
  get '/places/'+@testplace2.id.to_s

  assert :success
  assert_select "div#links_title", "Links:"
  assert_select "span#edit_links", false
  assert_select "div#linktitle0", "Place:"
  assert_select "div#linktext0", @testplace.name
  assert_select "div#linktitle1", "Route:"
  assert_select "div#linktext1", @testroute.name
  assert_select "div#linktitle2", "Trip:"
  assert_select "div#linktext2", @testtrip1.name
  assert_select "div#linktitle3", "Report:"
  assert_select "div#linktext3", @teststory1.name
  assert_select "div#linktitle5", "Url:"
  assert_select "div#linktext5", "http://stuff.nz/"
  assert_select "div#linktitle6", "About:"
  assert_select "div#linktext6", "About"

  assert_select "span[title=?]", @testphoto1.name
end

test "view links on routes page as stranger" do

  createLinks('route', @testroute2.id)
  get '/routes/'+@testroute2.id.to_s

  assert :success
  assert_select "div#links_title", "Links:"
  assert_select "span#edit_links", false
  assert_select "div#linktitle0", "Place:"
  assert_select "div#linktext0", @testplace.name
  assert_select "div#linktitle1", "Route:"
  assert_select "div#linktext1", @testroute.name
  assert_select "div#linktitle2", "Trip:"
  assert_select "div#linktext2", @testtrip1.name
  assert_select "div#linktitle3", "Report:"
  assert_select "div#linktext3", @teststory1.name
  assert_select "div#linktitle5", "Url:"
  assert_select "div#linktext5", "http://stuff.nz/"
  assert_select "div#linktitle6", "About:"
  assert_select "div#linktext6", "About"

  assert_select "span[title=?]", @testphoto1.name
end

test "view links on trips page as stranger" do

  createLinks('trip', @testtrip2.id)
  get '/trips/'+@testtrip2.id.to_s

  assert :success
  assert_select "div#links_title", "Links:"
  assert_select "span#edit_links", false
  assert_select "div#linktitle0", "Place:"
  assert_select "div#linktext0", @testplace.name
  assert_select "div#linktitle1", "Route:"
  assert_select "div#linktext1", @testroute.name
  assert_select "div#linktitle2", "Trip:"
  assert_select "div#linktext2", @testtrip1.name
  assert_select "div#linktitle3", "Report:"
  assert_select "div#linktext3", @teststory1.name
  assert_select "div#linktitle5", "Url:"
  assert_select "div#linktext5", "http://stuff.nz/"
  assert_select "div#linktitle6", "About:"
  assert_select "div#linktext6", "About"

  assert_select "span[title=?]", @testphoto1.name
end

test "view links on reports page as stranger" do

  createLinks('report', @teststory2.id)
  get '/reports/'+@teststory2.id.to_s

  assert :success
  assert_select "div#links_title", "Links:"
  assert_select "span#edit_links", false
  assert_select "div#linktitle0", "Place:"
  assert_select "div#linktext0", @testplace.name
  assert_select "div#linktitle1", "Route:"
  assert_select "div#linktext1", @testroute.name
  assert_select "div#linktitle2", "Trip:"
  assert_select "div#linktext2", @testtrip1.name
  assert_select "div#linktitle3", "Report:"
  assert_select "div#linktext3", @teststory1.name
  assert_select "div#linktitle5", "Url:"
  assert_select "div#linktext5", "http://stuff.nz/"
  assert_select "div#linktitle6", "About:"
  assert_select "div#linktext6", "About"

  assert_select "span[title=?]", @testphoto1.name
end

test "view links on photos page as stranger" do

  createLinks('photo', @testphoto2.id)
  get '/photos/'+@testphoto2.id.to_s

  assert :success
  assert_select "div#links_title", "Links:"
  assert_select "span#edit_links", false
  assert_select "div#linktitle0", "Place:"
  assert_select "div#linktext0", @testplace.name
  assert_select "div#linktitle1", "Route:"
  assert_select "div#linktext1", @testroute.name
  assert_select "div#linktitle2", "Trip:"
  assert_select "div#linktext2", @testtrip1.name
  assert_select "div#linktitle3", "Report:"
  assert_select "div#linktext3", @teststory1.name
  assert_select "div#linktitle5", "Url:"
  assert_select "div#linktext5", "http://stuff.nz/"
  assert_select "div#linktitle6", "About:"
  assert_select "div#linktext6", "About"

  assert_select "span[title=?]", @testphoto1.name
end

test "view common links as icons" do

    @l1=Link.create(item_id:nil, item_type: 'URL', baseItem_id:@testplace2.id, baseItem_type: 'place', item_url: "http://doc.govt.nz/places/blahh" )
    @l2=Link.create(item_id:nil, item_type: 'URL', baseItem_id:@testplace2.id, baseItem_type: 'place', item_url: "http://hutbagger.co.nz/huts/bobs-hut" )
    @l3=Link.create(item_id:nil, item_type: 'URL', baseItem_id:@testplace2.id, baseItem_type: 'place', item_url: "http://tramper.nz/1" )
  get '/places/'+@testplace2.id.to_s

  assert :success
  #not listed as links
  assert_select "div#links_title", "Links:"
  assert_select "div#linktitle0", false

  assert_select "img[alt='Doc logo']"
  assert_select "img[alt='Tramper logo']"
  assert_select "img[alt='Hutbagger plus1 logo']"

end

test "view links on about page as stranger" do

  createLinks('report', @teststory1.id)
  get '/about/'

  assert_select "div#report_list", /Test report 1 by Example user1 \(last updated .*/
end

#user can add links to anyhting, whoever the owner
test "view links as user" do
   login_as(@testuser2.name,"password")
   assert is_logged_in?
   @ouruser=User.find_by_id(session[:user_id])

  get '/places/'+@testplace.id.to_s
  assert_select "span#edit_links"

  get '/routes/'+@testroute.id.to_s
  assert_select "span#edit_links"

  get '/photos/'+@testphoto1.id.to_s
  assert_select "span#edit_links"

  get '/trips/'+@testtrip1.id.to_s
  assert_select "span#edit_links"

  get '/reports/'+@teststory1.id.to_s
  assert_select "span#edit_links"
end

#guest cannot add links even to their own trip
test "view links as guest" do
   add_place_to_trip(@testplace)
   @ourguest=Guest.find_by_id(session[:guest_id])
   assert is_guest?
   trip=@ourguest.currenttrip_id

  get '/places/'+@testplace.id.to_s
  assert_select "span#edit_links", false

  get '/routes/'+@testroute.id.to_s
  assert_select "span#edit_links", false

  get '/photos/'+@testphoto1.id.to_s
  assert_select "span#edit_links", false

  get '/trips/'+trip.to_s
  assert_select "span#edit_links", false

  get '/reports/'+@teststory1.id.to_s
  assert_select "span#edit_links", false
end

end

# controller talks about 'page'.... ehat is that. Should it be 'about'?

