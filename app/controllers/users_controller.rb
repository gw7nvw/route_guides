class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :show] 
  def show
    if(!(@user = User.find_by_id(params[:id]))) 
      redirect_to '/'
    end
  end

  def new
    @user = User.new

    # generate a security question and store it for this session 
    @id1= rand(Securityquestion.count)+Securityquestion.minimum(:id)
    @id2= rand(Securityquestion.count)+Securityquestion.minimum(:id)
    @op= rand(Securityoperator.count)+Securityoperator.minimum(:id)
    session[:id1]=@id1
    session[:id2]=@id2
    session[:op]=@op
  end

 def create
    @user = User.new(user_params)

    expected = Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer)
    if params['user'][:answer].to_i!=expected
      flash[:error] = "You got the to the question wrong.  This question is intended to ensure that you are a real person"
        # generate a new security question and store it for this session 
        @id1= rand(Securityquestion.count)+Securityquestion.minimum(:id)
        @id2= rand(Securityquestion.count)+Securityquestion.minimum(:id)
        @op= rand(Securityoperator.count)+Securityoperator.minimum(:id)
        session[:id1]=@id1
        session[:id2]=@id2
        session[:op]=@op

       render 'new'
    else
      @trip=Trip.new
      @trip.createdBy = @user
      @trip.name="default"
      @trip.save

      @user.currenttrip=@trip
      @user.role=Role.find_by(:name => 'user')

      if @user.save
        # clear the security question coz we're tidy kiwis 
        session[:id1]=nil
        session[:id2]=nil
        session[:op]=nil

        sign_in @user
        flash[:success] = "Welcome to the Route Guides"
        redirect_to @user
      else
        new()
        render 'new'
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    if((@user.id!=@current_user.id) and (@current_user.role!=Role.find_by( :name => 'root')))
      redirect_to @user
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "User details updated"

      # Handle a successful update.
      redirect_to @user
    else
      render 'edit'
    end
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end


    # Before filters

end
