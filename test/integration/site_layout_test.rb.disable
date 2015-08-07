require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 3
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", find_path
    assert_select "a[href=?]", search_path
    assert_select "a[href=?]", places_path
    assert_select "a[href=?]", '/legs'
    assert_select "a[href=?]", reports_path
    assert_select "a[href=?]", trips_path
    assert_select "a[href=?]", photos_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", '/routes/xps'
    assert_select "a[href=?]", '/places/new'
    assert_select "a[href=?]", '/routes/new'
    assert_select "a[href=?]", '/reports/new'
    assert_select "a[href=?]", '/photos/new'
    assert_select "a[href=?]", forums_path
    assert_select "a[href=?]", signin_path
#dont get loggedin stuff
    assert_select "a[href=?]", drafts_path, false
    assert_select "a[href=?]", wishlist_path, false
    assert_select "a[href=?]", '/currenttrip', false
    assert_select "a[href=?]", '/trips/new', false
    assert_select "a[href=?]", signout_path, false


  end
  test "layout_links loggedin" do
     @testrole = Role.new(name: "user", id: 1)
     @testrole.save
     @testuser = User.new(name: "Example User", email: "user@example.com",
                     password: "password", password_confirmation: "password", firstName: "test", lastName: "test2", role_id: 1)
     @testuser.activate
     @testuser.save
     get signin_path
     post sessions_path, session: { email: @testuser.email, password: 'password' }
     assert_redirected_to root_path
     follow_redirect!
     assert_select "a[href=?]", drafts_path
     assert_select "a[href=?]", wishlist_path
     assert_select "a[href=?]", '/currenttrip', false
     assert_select "a[href=?]", '/trips/new'
     assert_select "a[href=?]", signout_path
  end

  test "layout_links hastrip" do
     @testrole = Role.new(name: "user", id: 1)
     @testrole.save
     @testuser = User.new(name: "Example User", email: "user@example.com",
                     password: "password", password_confirmation: "password", firstName: "test", lastName: "test2", role_id: 1)
     @testuser.activate
     @testuser.save
     get signin_path
     post sessions_path, session: { email: @testuser.email, password: 'password' }
     assert_redirected_to root_path
     follow_redirect!
     @testtrip=Trip.new(:name=>'test', :createdBy=>@testuser)
     @testtrip.save
     @testuser.currenttrip=@testtrip
     @testuser.save
     get root_path
     assert_select "a[href=?]", '/currenttrip'
  end

end
