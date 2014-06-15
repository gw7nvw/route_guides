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

end
