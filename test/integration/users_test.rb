require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest

  def setup
    init()
  end

  test "should get users when not logged in" do
    get signup_path
    post users_path, user: { name:  "test1",
                               email: " test1@invalid.net ",
                               firstName: "test1a ",
                               lastName: "test1b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 0,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user1 = assigns(:user)
    get '/users/'+user1.name
    assert_response :success
    assert_select "title", "#{@base_title} | User | "+user1.name
    assert_select "div#page_title", user1.name.capitalize
    assert_select "div#realname", user1.firstName.capitalize+" "+user1.lastName.capitalize
    assert_select "div#lastvisited", "Last visited: Never"
    assert_select "div#email", false
    assert_select "div#editbutton", false
  end

  test "should get anonymous users when not logged in" do
    get signup_path
    post users_path, user: { name:  "test2",
                               email: "test2@invalid.net ",
                               firstName: "test 2a",
                               lastName: "test 2b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user2 = assigns(:user)
    get '/users/'+user2.name
    assert_response :success
    assert_select "title", "#{@base_title} | User | "+user2.name
    assert_select "div#page_title", user2.name.capitalize
    assert_select "div#realname", "Anonymous"
    assert_select "div#lastvisited", "Last visited: Never"
    assert_select "div#email", false
    assert_select "div#editbutton", false
  end

  test "last visted shown once a user has activated & logged in" do
    get signup_path
    post users_path, user: { name:  "test1",
                               email: " test1@invalid.net ",
                               firstName: "test1a ",
                               lastName: "test1b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 0,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user1 = assigns(:user)
    #activate & login
    get edit_account_activation_path(id: user1.activation_token, email: user1.email)
    follow_redirect!
    assert_template 'users/show'
    assert_select  "div.alert", "Account activated!"
    assert is_logged_in?
    delete signout_path
    follow_redirect!
    assert_not is_logged_in?
    user1.reload
    assert user1.lastVisited > 5.seconds.ago

    get '/users/'+user1.name
    assert_response :success
    assert_select "title", "#{@base_title} | User | "+user1.name
    assert_select "div#page_title", user1.name.capitalize
    assert_select "div#realname", user1.firstName.capitalize+" "+user1.lastName.capitalize
    assert_select "div#lastvisited", "Last visited: "+user1.lastVisited.strftime("%F %T")
    assert_select "div#email", false
    assert_select "div#editbutton", false
  end

  test "logged in user can see others details as-per guest" do
    get signup_path
    post users_path, user: { name:  "test1",
                               email: " test1@invalid.net ",
                               firstName: "test1a ",
                               lastName: "test1b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 0,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user1 = assigns(:user)
    get signup_path
    post users_path, user: { name:  "test2",
                               email: "test2@invalid.net ",
                               firstName: "test 2a",
                               lastName: "test 2b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user2 = assigns(:user)
    get '/users/'+user2.name

    #activate & login
    get edit_account_activation_path(id: user1.activation_token, email: user1.email)
    follow_redirect!
    assert_template 'users/show'
    assert_select  "div.alert", "Account activated!"
    assert is_logged_in?

    get '/users/'+user2.name
    assert_response :success
    assert_select "title", "#{@base_title} | User | "+user2.name
    assert_select "div#page_title", user2.name.capitalize
    assert_select "div#realname", "Anonymous"
    assert_select "div#lastvisited", "Last visited: Never"
    assert_select "div#email", false
    assert_select "div#editbutton", false
  end
  test "logged in user can see self and edit" do
    get signup_path
    post users_path, user: { name:  "test2",
                               email: "test2@invalid.net ",
                               firstName: "test 2a",
                               lastName: "test 2b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user2 = assigns(:user)
    get '/users/'+user2.name

    #activate & login
    get edit_account_activation_path(id: user2.activation_token, email: user2.email)
    follow_redirect!
    assert_template 'users/show'
    assert_select  "div.alert", "Account activated!"
    assert is_logged_in?
    user2.reload
    
    get '/users/'+user2.name
    assert_response :success
    assert_select "title", "#{@base_title} | User | "+user2.name
    assert_select "div#page_title", user2.name.capitalize
    assert_select "div#realname", user2.firstName.capitalize+" "+user2.lastName.capitalize
    assert_select "div#lastvisited", "Last visited: "+user2.lastVisited.strftime("%F %T")
    assert_select "div#email", "Email: "+user2.email
    assert_select "div#editbutton", "Edit"
  end

#edit works (no password change)
  test "logged in user can edit self" do
    get signup_path
    post users_path, user: { name:  "test2",
                               email: "test2@invalid.net ",
                               firstName: "test 2a",
                               lastName: "test 2b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user2 = assigns(:user)
    get '/users/'+user2.name

    #activate & login
    get edit_account_activation_path(id: user2.activation_token, email: user2.email)
    follow_redirect!
    assert_template 'users/show'
    assert_select  "div.alert", "Account activated!"
    assert is_logged_in?
    user2.reload

    #view screen
    get '/users/'+user2.name
    assert_response :success
    assert_select "div#editbutton", "Edit"

    #edit
    get '/users/'+user2.name+"/edit"
    assert_response :success
    assert_select "title", "#{@base_title} | Edit User | "+user2.name
    assert_select 'input#user_name' do
      assert_select "[value=?]", user2.name
    end
    assert_select 'input#user_firstName' do
      assert_select "[value=?]", user2.firstName
    end
    assert_select 'input#user_lastName' do
      assert_select "[value=?]", user2.lastName
    end
    assert_select 'input#user_hide_name' do
      assert_select "[value=?]", if user2.hide_name then 1 else 0 end
    end
    assert_select 'input#user_email' do
      assert_select "[value=?]", user2.email
    end
    assert_select 'input#user_password' do
      assert_select "[type=?]", "password"
    end
    assert_select 'input#user_password_confirmation' do
      assert_select "[type=?]", "password"
    end
    assert_select 'input.btn' do
      assert_select "[value=?]", "Save changes"
    end

    #change and save
    patch "/users/"+user2.id.to_s, user: { name:  "atest1",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b ",
                               password: nil,
                               password_confirmation: nil,
                               hide_name: 1
    }
    follow_redirect!
    assert_select  "div.alert", "User details updated"
    user2.reload
    assert_select "title", "#{@base_title} | User | atest1"
    assert_select "div#page_title", "Atest1"
    assert_select "div#realname", "Atest1a Atest1b"
    assert_select "div#lastvisited", "Last visited: "+user2.lastVisited.strftime("%F %T")
    assert_select "div#email", "Email: atest1@invalid.net"
    assert_select "div#editbutton", "Edit"
    assert_equal user2.hide_name, true 
    
    #check can still login using old password
    delete signout_path
    follow_redirect!
    assert_not is_logged_in?
    login_as(user2.name, "foo")
    assert is_logged_in?
  end

#edit works (password change)
  test "edit can change password" do
    get signup_path
    post users_path, user: { name:  "test2",
                               email: "test2@invalid.net ",
                               firstName: "test 2a",
                               lastName: "test 2b",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }

    user2 = assigns(:user)
    get '/users/'+user2.name

    #activate & login
    get edit_account_activation_path(id: user2.activation_token, email: user2.email)
    follow_redirect!
    assert is_logged_in?
    user2.reload

    #change and save
    patch "/users/"+user2.id.to_s, user: { name:  "atest1",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b ",
                               password: "bar",
                               password_confirmation: "bar",
                               hide_name: 1
    }

    follow_redirect!
    assert_select  "div.alert", "User details updated"
    user2.reload
    assert_select "title", "#{@base_title} | User | atest1"
    assert_select "div#page_title", "Atest1"
    assert_select "div#realname", "Atest1a Atest1b"
    assert_select "div#lastvisited", "Last visited: "+user2.lastVisited.strftime("%F %T")
    assert_select "div#email", "Email: atest1@invalid.net"
    assert_select "div#editbutton", "Edit"
    assert_equal user2.hide_name, true

    #check can still login using old password
    delete signout_path
    follow_redirect!
    assert_not is_logged_in?
    login_as(user2.name, "bar")
    assert is_logged_in?
end

#cannot edit someone else using URL
test "cannot edit another user" do
    login_as(@testuser.name, "password")
    assert is_logged_in?

    #try to edit another user 
    get "/users/"+URI.escape(@testuser2.name)+"/edit" 
    #get resirected to show page
    follow_redirect!
    assert_select "title", "#{@base_title} | User | "+@testuser2.name
    assert_select "div#page_title", @testuser2.name.capitalize
    assert_select "div#editbutton", false
end
#cannot edit someone else using PATCH
test "canot change another user using patch" do
    login_as(@testuser.name, "password")
    assert is_logged_in?
    #try to patch anothe ruser
    patch "/users/"+@testuser2.id.to_s, user: { name:  "atest1",
                              email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b ",
                               password: "bar",
                               password_confirmation: "bar",
                               hide_name: 1
    }
    follow_redirect!
    assert_select "title", "#{@base_title}"
end
    

#root can see everyones details
test "root can see / edit anyone" do 
    login_as(@testuser3.name, "password")
    assert is_logged_in?

    #View another user.  Verify root can see everything
    get '/users/'+URI.escape(@testuser.name)
    assert_response :success
    assert_select "title", "#{@base_title} | User | "+@testuser.name
    assert_select "div#page_title", @testuser.name.capitalize
    assert_select "div#realname", @testuser.firstName.capitalize+" "+@testuser.lastName.capitalize
    assert_select "div#lastvisited", "Last visited: Never"
    assert_select "div#email", "Email: "+@testuser.email
    assert_select "div#editbutton", "Edit"
#root can edit someone else (no passwd)
    #edit
    get '/users/'+URI.escape(@testuser.name)+"/edit"
    assert_response :success
    assert_select "title", "#{@base_title} | Edit User | "+@testuser.name
    assert_select 'input#user_name' do
      assert_select "[value=?]", @testuser.name
    end
    assert_select 'input#user_firstName' do
      assert_select "[value=?]", @testuser.firstName
    end
    assert_select 'input#user_lastName' do
      assert_select "[value=?]", @testuser.lastName
    end
    assert_select 'input#user_hide_name' do
      assert_select "[value=?]", if @testuser.hide_name then 1 else 0 end
    end
    assert_select 'input#user_email' do
      assert_select "[value=?]", @testuser.email
    end
    assert_select 'input#user_password' do
      assert_select "[type=?]", "password"
    end
    assert_select 'input#user_password_confirmation' do
      assert_select "[type=?]", "password"
    end
    assert_select 'input.btn' do
      assert_select "[value=?]", "Save changes"
    end

    #change and save
    patch "/users/"+@testuser.id.to_s, user: { name:  "atest1",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b ",
                               password: nil,
                               password_confirmation: nil,
                               hide_name: 1
    }
    follow_redirect!
    assert_select  "div.alert", "User details updated"
    @testuser.reload
    assert_select "title", "#{@base_title} | User | atest1"
    assert_select "div#page_title", "Atest1"
    assert_select "div#realname", "Atest1a Atest1b"
    assert_select "div#lastvisited", "Last visited: Never"
    assert_select "div#email", "Email: atest1@invalid.net"
    assert_select "div#editbutton", "Edit"
    assert_equal @testuser.hide_name, true

    #check can still login using old password
    delete signout_path
    follow_redirect!
    assert_not is_logged_in?
    login_as(@testuser.name, "password")
    assert is_logged_in?
end


#root can reset someone elses password
test "root can chaneg other users passwords" do
    login_as(@testuser3.name, "password")
    assert is_logged_in?
    patch "/users/"+@testuser.id.to_s, user: { name:  "atest1",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b ",
                               password: "foo",
                               password_confirmation: "foo",
                               hide_name: 1
    }
    follow_redirect!
    assert_select  "div.alert", "User details updated"
    @testuser.reload
    assert_select "title", "#{@base_title} | User | atest1"
    assert_select "div#page_title", "Atest1"
    assert_select "div#realname", "Atest1a Atest1b"
    assert_select "div#lastvisited", "Last visited: Never"
    assert_select "div#email", "Email: atest1@invalid.net"
    assert_select "div#editbutton", "Edit"
    assert_equal @testuser.hide_name, true

    #check can still login using old password
    delete signout_path
    follow_redirect!
    assert_not is_logged_in?
    login_as(@testuser.name, "foo")
    assert is_logged_in?
end

#invalid values and cannot change role
test "invalid values in user form" do
    login_as(@testuser.name, "password")
    assert is_logged_in?
    patch "/users/"+@testuser.id.to_s, user: { name:  "",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b ",
                               password: "foo",
                               password_confirmation: "foo",
                               hide_name: 1
    }
    assert_template 'users/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name can&#39;t be blank"
 
    patch "/users/"+@testuser.id.to_s, user: { name:  " atest1 ",
                               email: " ",
                               firstName: " atest1a ",
                               lastName: " atest1b ",
                               password: "foo",
                               password_confirmation: "foo",
                               hide_name: 1
    }
    assert_template 'users/edit'
    assert_select  "div.alert", "The form contains 2 errors."
    assert_select  "div#error_explanation>ul" do
       assert_select 'li', "* Email can&#39;t be blank" or "Email is invalid"
    end



    patch "/users/"+@testuser.id.to_s, user: { name:  " atest1 ",
                               email: " atest1@invalid.net ",
                               firstName: "  ",
                               lastName: " atest1b ",
                               password: "foo",
                               password_confirmation: "foo",
                               hide_name: 1
    }
    assert_template 'users/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Firstname can&#39;t be blank"

    patch "/users/"+@testuser.id.to_s, user: { name:  " atest1 ",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: "  ",
                               password: "foo",
                               password_confirmation: "foo",
                               hide_name: 1
    }
    assert_template 'users/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Lastname can&#39;t be blank"

    patch "/users/"+@testuser.id.to_s, user: { name:  " atest1 ",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b  ",
                               password: "foo",
                               password_confirmation: "bar",
                               hide_name: 1
    }
    assert_template 'users/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Password confirmation doesn&#39;t match Password"

    patch "/users/"+@testuser.id.to_s, user: { name:  " Example User2  ",
                               email: " atest1@invalid.net ",
                               firstName: " atest1a ",
                               lastName: " atest1b  ",
                               password: "foo",
                               password_confirmation: "foo",
                               hide_name: 1
    }
    assert_template 'users/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name has already been taken"

    patch "/users/"+@testuser.id.to_s, user: { name:  " Example User1  ",
                               email: " user2@example.com ",
                               firstName: " atest1a ",
                               lastName: " atest1b  ",
                               password: "foo",
                               password_confirmation: "foo",
                               hide_name: 1
    }
    assert_template 'users/edit'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Email has already been taken"

    #check details unchanged
    get '/users/'+URI.escape(@testuser.name)
    assert_response :success
    assert_select "title", "#{@base_title} | User | "+@testuser.name
    assert_select "div#page_title", @testuser.name.capitalize
    assert_select "div#realname", @testuser.firstName.capitalize+" "+@testuser.lastName.capitalize
    assert_select "div#email", "Email: "+@testuser.email
    assert_select "div#editbutton", "Edit"

end

test "view nonexistant user" do
#view nonexistant trip
    get '/users/bobm8'
    follow_redirect!
    assert_template root_path
end

test "edit nonexistant user" do
#view nonexistant trip
    @edit=true
    get '/users/bobm8/edit'
    follow_redirect!
    assert_template root_path
end

end

