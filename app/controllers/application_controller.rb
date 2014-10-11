class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #  protect_from_forgery with: :exception
   
  include SessionsHelper
  include RgeoHelper

  def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def touch_user
    if signed_in? then
      @current_user.lastVisited=Time.new()
      @current_user.save
    end

  end

  def prepare_route_vars()
    @route_types = Routetype.all
    @gradients = Gradient.all
    @alpines = Alpine.all
    @alpinews = Alpinew.all
    @rivers = River.all
    @terrains = Terrain.all
  end

 
end
