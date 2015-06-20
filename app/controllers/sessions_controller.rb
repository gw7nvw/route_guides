class SessionsController < ApplicationController

  def new
  end

  def create
  user = User.find_by(email: params[:session][:email].downcase)
  if user && user.authenticate(params[:session][:password])
      if user.activated?
        sign_in user
        redirect_to root_url
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        message += "If you do not recieve an email within a few minutes (check your spam folder too), then use the forgotten password link to sign in."
        message += "Alternatively email mattbriggs@yahoo.com to request manual activation"

        flash[:error] = message
        render 'new'
      end
    # Sign the user in and redirect to the user's show page.
  else
      flash.now[:error] = 'Invalid email/password combination' 
      render 'new'
  end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
