class CommentsController < ApplicationController
# before_action :signed_in_user, only: [:edit, :update, :new, :create]


def index
    @order='latest'
    if signed_in? and @current_user.role_id>1 then 
      @comments=Comment.all.order('created_at desc').paginate(:per_page => 80, :page => params[:page])
    else
      @comments=Comment.where(:approved => true).order('created_at desc').paginate(:per_page => 80, :page => params[:page])
    end
end

def page_index
  if signed_in? and @current_user.role.id>1 then
    @comments=Comment.where(:item_type => @item_type, :item_id => @item_id)   
  else
    @comments=Comment.where(:approved => true, :item_type => @item_type, :item_id => @item_id)   
  end

end

def new

end


def create
   @comment_posted=true
   @comment=Comment.new(comment_params)
   @item_type=@comment.item_type
   @item_id=@comment.item_id
   @comment.approved=false
   if signed_in?
     @comment.createdBy_id=@current_user.id
     @comment.fromName=@current_user.name
     @comment.fromEmail=@current_user.email
     @comment.approved=true
   end


   errr=false

   dup=Comment.find_by_sql ['select * from comments where "comment"=? and "item_type"=? and "item_id"=? and "createdBy_id"=?',@comment.comment, @comment.item_type, @comment.item_id, @comment.createdBy_id]
   logger.debug dup.count
   if (session[:save] and (Time.now - session[:save])<60) or dup.count>0  then
       #save already in procgress
       logger.debug "errorwith 409"
       render nothing: true, status: 409
       errr=true
   end

   if @comment.approved==false and errr==false then
      auth=@comment.checkAuth
      case auth
      when "error"
        flash[:error] = "The name or email have been used by another user"
        errr=true
        page_index
        render 'page_index'
      when "true"
        @comment.approved=true
      when "suspended"
        flash[:error] = "Account suspended"
        errr=true
        page_index
        render 'page_index'
      else
        @comment.save
        if @comment.fromEmail  and @comment.fromEmail.length>0
          authlist=Authlist.create_or_replace(:address => @comment.fromEmail, :name => @comment.fromName, :allow => false, :forbid => false)
          if authlist
             authlist.send_auth_email
             flash[:info] = "Check your mail and authenticate your address"
           #  flash[:success] = "Comment submitted to moderator for approval."
          else
            @comment.approved=false
            flash[:success] = "Address validation failed. Comment submitted to moderator for approval."
          end
        else
          @comment.approved=false
          flash[:success] = "Comment submitted to moderator for approval."
# Providing your email address will avoid this step"
        end
      end
   end

   if errr==false then
      session[:save]=Time.now
      success=@comment.save
      session[:save]=nil
      if success
        @comment=Comment.new()
      end
      page_index
      render 'page_index'
   end
end


def update

end

def approve
    if (signed_in? and @current_user.role_id>1)
      comment=Comment.find_by_id(params[:selected_id])
      @item_type=comment.item_type
      @item_id=comment.item_id
      if comment
         comment.approved=true
         comment.save
      end
    end

    if params[:referring_page]=="index" then
      index
      render 'index'
    else
      page_index
      render 'page_index'
    end
end


def destroy
    comment=Comment.find_by_id(params[:selected_id])
    @item_type=comment.item_type
    @item_id=comment.item_id
    if (signed_in? and (@current_user.role_id>1 or @current_user.id == comment.fromUser_id))
      if comment
         comment.destroy
      end
    end

    if params[:referring_page]=="index" then
      index
      render 'index'
    else
      page_index
      render 'page_index'
    end
end

private
  def comment_params
    params.require(:comment).permit(:comment, :experienced_at, :item_type, :item_id, :fromName, :fromEmail)
  end

   end
