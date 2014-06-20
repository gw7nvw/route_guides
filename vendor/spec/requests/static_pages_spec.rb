require 'spec_helper'
describe "Static pages" do

  subject {page}
  describe "Home page" do

    before {visit root_path}

    it { should have_content('Route Guides') }
    it { should have_title('Route Guides') }
  end

  describe "About page" do

    before {visit about_path}

    it { should have_content('About') }
    it { should have_title('Route Guides | About') }
  end

  describe "Disclaimer page" do

    before {visit disclaimer_path}

    it { should have_content('Disclaimer') }
    it { should have_title('Route Guides | Disclaimer') }
  end

 it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title("About")
    click_link "Disclaimer"
    expect(page).to have_title('Disclaimer')
    click_link "Home"
    expect(page).to have_title('Route Guides')
    expect(page).to_not have_title('|')
    click_link "Sign up now!"
    expect(page).to have_title('Sign up')
    click_link "Route Guides"
    expect(page).to have_title('Route Guides')
    expect(page).to_not have_title('|')
  end
end
