class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :drafts] 
  def index
    @users=User.where(:activated=>true).order(:lastVisited).reverse
  end

  def show
    if(!(@user = User.where(name: params[:id]).first)) 
      redirect_to '/'
    end
  end

  def drafts
    @user=@current_user

    @trips=Trip.where('"createdBy_id" = ? and published = false',@current_user.id).order(:name)
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
    @user.name=@user.name.strip
    @user.firstName=@user.firstName.strip
    @user.lastName=@user.lastName.strip
    @user.email=@user.email.strip
    expected = Securityquestion.find_by_id(session[:id1].to_i).answer+(Securityoperator.find_by_id(session[:op].to_i).sign*Securityquestion.find_by_id(session[:id2].to_i).answer)
    if params['user'][:answer].to_i!=expected
      flash[:error] = "You got the to the question wrong. This question is intended to ensure that you are a real person"
        # generate a new security question and store it for this session 
        @id1= rand(Securityquestion.count)+Securityquestion.minimum(:id)
        @id2= rand(Securityquestion.count)+Securityquestion.minimum(:id)
        @op= rand(Securityoperator.count)+Securityoperator.minimum(:id)
        session[:id1]=@id1
        session[:id2]=@id2
        session[:op]=@op

       render 'new'
    else
      if is_guest? then
        @trip=@current_guest.currenttrip
      else
        @trip=Trip.new
        @trip.createdBy = @user
        @trip.name="default"
        @trip.save
      end

      @user.currenttrip=@trip
      @user.role=Role.find_by(:name => 'user')

      if @user.save
        @user.reload
        # resave trip with userID
        @trip.createdBy_id = @user.id
        @trip.save

        # clear the security question coz we're tidy kiwis 
        session[:id1]=nil
        session[:id2]=nil
        session[:op]=nil

        @user.send_activation_email
        flash[:info] = "Please check your email for details on how to activate your account"
        redirect_to '/signin'
#        sign_in @user
#        flash[:success] = "Welcome to the Route Guides"
#        redirect_to '/users/'+@user.name
      else
        # generate a security question and store it for this session 
        @id1= rand(Securityquestion.count)+Securityquestion.minimum(:id)
        @id2= rand(Securityquestion.count)+Securityquestion.minimum(:id)
        @op= rand(Securityoperator.count)+Securityoperator.minimum(:id)
        session[:id1]=@id1
        session[:id2]=@id2
        session[:op]=@op

        render 'new'
      end
    end
  end

  def edit
    @user = User.where(name: params[:id]).first
    if((@user.id!=@current_user.id) and (@current_user.role!=Role.find_by( :name => 'root')))
        redirect_to '/users/'+URI.escape(@user.name)
    end
  end

  def update
    @user = User.find_by_id(params[:id])
    if @current_user==@user or @current_user.role.name=="root" then
      @user.assign_attributes(user_params)
      @user.name=@user.name.strip
      @user.firstName=@user.firstName.strip
      @user.lastName=@user.lastName.strip
      @user.email=@user.email.strip
      if @user.save 
        flash[:success] = "User details updated"
  
        # Handle a successful update.
        redirect_to '/users/'+URI.escape(@user.name)
      else
        render 'edit'
      end
    else
      redirect_to root_path
    end
  end


  private

    def user_params
      params.require(:user).permit(:name, :firstName, :lastName, :email, :password, :hide_name, 
                                   :password_confirmation)
    end


    # Before filters

end
