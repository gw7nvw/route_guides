require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
     @role=Role.new(name: "users", id: 1)
     @role.save
     @user=User.new(name: "test", firstName: "test1", lastName: "test2", email: "test@test.net", password: "test",password_confirmation: "test", role: @role)
  end

    test "valid user" do
       assert @user.valid?
    end

    test "missing name" do
      @user.name=nil
      assert_not @user.valid?

      @user.name="    "
      assert_not @user.valid?


      @user.name="test"
      assert @user.valid?
    end


    test "missing role" do
      @user.role_id=nil
      assert_not @user.valid?

      @user.role_id=2
      assert_not @user.valid?

      @user.role_id=@role.id
      assert @user.valid?
    end


    test "missing real names" do
      @user.firstName="    "
      assert_not @user.valid?

      @user.firstName="test1"
      @user.lastName=" "
      assert_not @user.valid?

      @user.lastName="test2"
      assert @user.valid?
    end

    test "email" do
      @user.email=nil
      assert_not @user.valid?

      @user.email="test"
      assert_not @user.valid?

      @user.email="test@"
      assert_not @user.valid?

      @user.email="@test"
      assert_not @user.valid?

      @user.email="test@test.net"
      assert @user.valid?
    end

    test "touch" do
      @user.save
      sleep 10
      old_updated_at=@user.updated_at
      @user.touch
      assert @user.updated_at>old_updated_at 
    end

    test "activate" do
      @user.create_activation_digest 
      assert @user.authenticated?('activation',@user.activation_token)
    end

    test "password_reset" do
      @user.create_reset_digest 
      assert @user.authenticated?('reset',@user.reset_token)
      assert @user.reset_sent_at > 5.seconds.ago
      assert_not @user.password_reset_expired?
    end
end

