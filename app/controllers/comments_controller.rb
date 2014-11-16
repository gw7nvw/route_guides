class CommentsController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]


def index
end


def new

end


def create
   @comment=Comment.new(comment_params)
   @item_type=@comment.item_type
   @item_id=@comment.item_id

   @comment.createdBy_id=@current_user.id

   dup=Comment.find_by_sql ['select * from comments where "comment"=? and "item_type"=? and "item_id"=? and "createdBy_id"=?',@comment.comment, @comment.item_type, @comment.item_id, @comment.createdBy_id]
   logger.debug dup.count
   if (session[:save] and (Time.now - session[:save])<60) or dup.count>0  then
       #save already in procgress
       logger.debug "errorwith 409"
       render nothing: true, status: 409
   else
      session[:save]=Time.now
      success=@comment.save
      session[:save]=nil
      if success
        @comment=nil
        index
        render 'index'
      else
        index
        render 'index'
      end

   end
end


def update

end

private
  def comment_params
    params.require(:comment).permit(:comment, :experienced_at, :item_type, :item_id)
  end

   end
