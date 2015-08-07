require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    init()
  end

test "can create user with valid chars" do

  @testuser = User.create(name: "Valid name 12", email: "zzzzz@example.com", password: "password", password_confirmation: "password", firstName: "test1a", lastName: "test1b", role_id: 1, hide_name: true)
  assert_equal @testuser.errors.messages.count, 0
 
end

test "cannot create user with invalid chars" do
  @testuser = User.create(name: "i@i", email: "yyyyy@example.com", password: "password", password_confirmation: "password", firstName: "test1a", lastName: "test1b", role_id: 1, hide_name: true)
  assert_equal @testuser.errors.messages.count, 1
end
end
