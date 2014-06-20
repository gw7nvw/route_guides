require 'spec_helper'

describe Place do
  let(:user) { FactoryGirl.create(:user) }
before do
#  @user = User.new(name: "Example User", email: "user@example.com",
#                       password: "foofoo", password_confirmation: "foofoo" )


  @place = Place.new(name: "Example place", 
  		description: "an example place",
		location: 'POINT(41.2889 174.7772)',
		altitude: 1000,
		createdBy_id: user.id ) 
end

  subject { @place }

  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:location) }
  it { should respond_to(:altitude) }
  it { should respond_to(:createdBy) }
  its(:createdBy) { should eq user }

  it { should be_valid }

  describe "when name is not present" do
    before { @place.name = " " }
    it { should_not be_valid }
  end

  describe "when location is not present" do
    before { @place.location = nil }
    it { should_not be_valid }
  end

  describe "when createdByUserId is not present" do
    before { @place.createdBy_id = nil }
    it { should_not be_valid }
  end

  describe "when createdByUserId is 0" do
    before { @place.createdBy_id = 0 }
    it { should_not be_valid }
  end

end
