require 'spec_helper'



describe "Places pages" do

  subject { page }
    let!(:createdBy) { FactoryGirl.create(:createdBy) }
    let!(:place) { FactoryGirl.create(:place, createdBy: createdBy) }
  # Replace with code to make a user variable
    describe "without signin" do
      describe "new place not allowed" do

        before { visit '/places/new' }

        it { should have_title('Sign in') }
      end

      describe "new place not allowed" do

        before { visit edit_place_path(place) }

        it { should have_title('Sign in') }
      end
 
      describe "view place allowed" do

        before { visit  place_path(place) }

        it { should have_title('NZ Route Guides | New Place') }
      end

   end


    describe "after signin do" do
      before do
        visit signin_path
        fill_in "Email",    with: createdBy.email.upcase
        fill_in "Password", with: createdBy.password
        click_button "Sign in"
      end

      subject { page }

      describe "new page" do

        before { visit '/places/new' }

        it { should have_content('New Place') }
        it { should have_title('NZ Route Guides | New Place') }
        it  {should have_content('Projlib installed: true') }

      end

      describe "view place allowed" do

        before { visit  place_path(place) }

        it { should have_title('NZ Route Guides | New Place') }
      end


      describe "index" do
        before do
          visit places_path
        end

        it { should have_title('Places') }
        it { should have_content('Places') }

        it "should list each place" do
          Place.all.each do |place|
            expect(page).to have_selector('li', text: place.name)
          end
        end
      end
    end
end
