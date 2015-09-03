class AddressAuthsController < ApplicationController

  def edit
    authlist = Authlist.find_by(address: params[:email])
    if authlist && !authlist.allow && !authlist.forbid && authlist.authenticated?(:auth, params[:id])
      authlist.activate
      flash[:success] = "Address authenticated!"
      redirect_to '/forums/'
    else
      flash[:danger] = "Invalid authentication link"
      redirect_to root_url
    end
  end
end
