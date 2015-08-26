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
    @l7=Link.create(item_id:nil, item_type: 'URL', baseItem_id:baseId, baseItem_type: baseType, item_url: "http://tramper.nz/" )
    @l8=Link.create(item_id:nil, item_type: 'about', baseItem_id:baseId, baseItem_type: baseType, item_url: "http://routeguires.co.nz/users" )
  end


test "edit links on places page as user" do
   login_as(@testuser2.name,"password")
   assert is_logged_in?
   @ouruser=User.find_by_id(session[:user_id])

  createLinks('place', @testplace2.id)
  get '/places/'+@testplace2.id.to_s+"?editlinks=true"

  assert :success
  assert_select "div#links_title", "Edit Links:"
  assert_select "span#edit_links", false
  assert_select "div#linktitle0", "Place:"
  assert_select "div#linktext0", @testplace.name
  assert_select "div#linktitle1", "Route:"
  assert_select "div#linktext1", @testroute.name
  assert_select "div#linktitle2", "Trip:"
  assert_select "div#linktext2", @testtrip1.name
  assert_select "div#linktitle3", "Report:"
  assert_select "div#linktext3", @teststory1.name
  assert_select "div#linktitle4", "Photo:"
  assert_select "div#linktext4", @testphoto1.name
  assert_select "div#linktitle5", "Url:"
  assert_select "div#linktext5", "http://stuff.nz/"
  assert_select "div#linktitle6", "About:"
  assert_select "div#linktext6", "About"
  assert_select "input#deletelink", 7    #delete for each row
  #add link row
  assert_select "div#add-link"
  assert_select "input#itemType"
  assert_select "input#itemName"
  assert_select "input#linkplus", 1

  #search buttons
  assert_select "img#link-select-on"
  assert_select 'img#link-select-off[style="display:none"]'
  assert_select "img#searchon"
  assert_select 'img#searchoff[style="display:none"]'
  assert_select "img#hyperlinkon"
  assert_select 'img#hyperlinkoff[style="display:none"]'
end

#would need non-javascript implementations for search, add, delete for any of this to be tested here...

#search and add place
#search and add route
#search and add trip
#search and add report
#search and add photo
#serach and add about (root)
#serach cannot add about (user)
#serach and cancel
#search no results
#add http hyperlink and add
#add https hyperlink and add
#add hyperlink no protocol and add
#add hyperlink and cancel
#delete link

#links on edit route
#links on edit -ve route
#links on edit trip
#links on edit report
#links on edit photo

#guest / stranger cannot edit / add / delete

end
