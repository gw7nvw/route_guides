class StaticPagesController < ApplicationController
 before_action :touch_user

  def home
       @static_page=true
  end

  def about
  end

  def reload
  end

end
