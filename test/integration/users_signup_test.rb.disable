require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

def setup
init()
end

  test "valid signup information" do
    get '/signup'
    oldusercount=User.all.count
    oldtripcount=Trip.all.count
    post users_path, user: { name:  " test 3 ",
                               email: " test3@invalid.net ",
                               firstName: " test 1 ",
                               lastName: " test 2 ",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 0,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    assert User.all.count==oldusercount+1
    assert Trip.all.count==oldtripcount+1
    assert_redirected_to signin_path
    follow_redirect!
    assert_select  "div.alert", "Please check your email for details on how to activate your account" 
    @testuser2=User.last
    assert @testuser2.name=="test 3"
    assert @testuser2.firstName=="test 1"
    assert @testuser2.lastName=="test 2"
    assert @testuser2.email=="test3@invalid.net"
    assert @testuser2.hide_name==false
    assert @testuser2.role.name=="user"
  end

  test "valid signup information2" do
    get '/signup'
    oldusercount=User.all.count
    oldtripcount=Trip.all.count
    post users_path, user: { name:  " test 4 ",
                               email: " test4@invalid.net ",
                               firstName: " test 1 ",
                               lastName: " test 2 ",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    assert User.all.count==oldusercount+1
    assert Trip.all.count==oldtripcount+1
    assert_redirected_to signin_path
    follow_redirect!
    assert_select  "div.alert", "Please check your email for details on how to activate your account" 
    @testuser2=User.last
    assert @testuser2.name=="test 4"
    assert @testuser2.firstName=="test 1"
    assert @testuser2.lastName=="test 2"
    assert @testuser2.email=="test4@invalid.net"
    assert @testuser2.hide_name==true
    assert @testuser2.role.name=="user"
  end

  test "duplicate email" do
    get '/signup'
    post users_path, user: { name:  " test 4 ",
                               email: " test4@invalid.net ",
                               firstName: " test 1 ",
                               lastName: " test 2 ",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    follow_redirect!


    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "test 5",
                               email: "test4@invalid.net",
                               firstName: "test1",
                               lastName: "test2",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    end
    assert_template 'users/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Email has already been taken"
  end

  test "duplicate name" do
    get '/signup'
    post users_path, user: { name:  " test 4 ",
                               email: " test4@invalid.net ",
                               firstName: " test 1 ",
                               lastName: " test 2 ",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               hide_name: 1,
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    follow_redirect!


    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "test 4",
                               email: "test5@invalid.net",
                               firstName: "test1",
                               lastName: "test2",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    end
    assert_template 'users/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name has already been taken"
  end

  test "invalid password information" do
    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "test3",
                               email: "test3@invalid.net",
                               firstName: "test1",
                               lastName: "test2",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "bar",
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    end
    assert_template 'users/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Password confirmation doesn&#39;t match Password"
  end

  test "invalid name information" do
    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  " ",
                               email: "test3@invalid.net",
                               firstName: "test1",
                               lastName: "test2",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    end
    assert_template 'users/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Name can&#39;t be blank"
  end


  test "invalid firstname information" do
    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "test4 ",
                               email: "test3@invalid.net",
                               firstName: "",
                               lastName: "test2",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    end
    assert_template 'users/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Firstname can&#39;t be blank"
  end
  test "invalid lastname information" do
    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "test4 ",
                               email: "test3@invalid.net",
                               firstName: "test1",
                               lastName: "",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    end
    assert_template 'users/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Lastname can&#39;t be blank"
  end
  test "invalid email information" do
    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "test4 ",
                               email: "test3@invalid",
                               firstName: "test1",
                               lastName: "test2",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               answer: Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer) }
    end
    assert_template 'users/new'
    assert_select  "div.alert", "The form contains 1 error."
    assert_select  "div#error_explanation>ul>li", "* Email is invalid"
  end

  test "invalid security question information" do
    get '/signup'
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "test4 ",
                               email: "test3@invalid",
                               firstName: "test1",
                               lastName: "test2",
                               role_id: @testrole.id,
                               password:              "foo",
                               password_confirmation: "foo",
                               answer: 99}
    end
    assert_template 'users/new'
    assert_select  "div.alert", "You got the to the question wrong. This question is intended to ensure that you are a real person"
  end

  test "valid signup information with account activation" do
    startDeliveries= ActionMailer::Base.deliveries.size
    assert_difference 'User.count', 1 do
      sign_up_as("test6", "password")
    end
    assert_equal startDeliveries+1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    follow_redirect!
    assert_select  "div.alert", "Please check your email for details on how to activate your account"
    assert_not user.activated?
    # Try to log in before activation.
    login_as(user.name, "password")
    assert_not is_logged_in?
    assert_select  "div.alert", "Account not activated. Check your email for the activation link.If you do not recieve an email within a few minutes (check your spam folder too), then use the forgotten password link to sign in.Alternatively email mattbriggs@yahoo.com to request manual activation"
    # Invalid activation token
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path( user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(id: user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert_select  "div.alert", "Account activated!"
    assert is_logged_in?
  end

  test "log out / log in valid user" do
    sign_up_as("test6", "password")
    user = assigns(:user)
    get edit_account_activation_path(id: user.activation_token, email: user.email)
    follow_redirect!
    assert is_logged_in?
    #log out
    delete signout_path 
    follow_redirect!
    assert_not is_logged_in?
    # log back in
    login_as(user.name, "password")
    assert_redirected_to root_path
    follow_redirect!
    assert is_logged_in?
    #log out
    delete signout_path 
    follow_redirect!
    assert_not is_logged_in?
    # log back in using email
    login_as(user.email, "password")
    assert_redirected_to root_path
    follow_redirect!
    assert is_logged_in?
  end

  test "invalid login" do
    sign_up_as("test6", "password")
    user = assigns(:user)
    get edit_account_activation_path(id: user.activation_token, email: user.email)
    follow_redirect!
    assert is_logged_in?
    #log out
    delete signout_path 
    follow_redirect!
    assert_not is_logged_in?
    # log back in
    login_as("wrongname", "password")
    assert_template 'sessions/new'
    assert_not is_logged_in?
    assert_select  "div.alert", "Invalid user/password combination"
    # log back in
    login_as(user.name, "wrongpassword")
    assert_template 'sessions/new'
    assert_not is_logged_in?
    assert_select  "div.alert", "Invalid user/password combination"
  end
end

