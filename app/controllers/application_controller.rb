class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
#  protect_from_forgery with: :exception
  include SessionsHelper
  include RgeoHelper

    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end

def prepare_route_vars()
    @route_types = Routetype.all
    @gradients = Gradient.all
    @alpines = Alpine.all
    @rivers = River.all
    @terrains = Terrain.all
end

end
