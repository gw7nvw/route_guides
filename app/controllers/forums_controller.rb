class ForumsController < ApplicationController
# before_action :signed_in_user, only: [:edit, :update, :new, :create]
 before_action :touch_user

def index
   @id=1
   show()
end


def show
   if signed_in? and @current_user.role_id>1 then appr_text="" else appr_text="approved=true and " end
   if !@id then @id=params[:id].to_i end
   if !@subject then @subject=params[:thread] end
   if @subject then 
      show_thread()
   else
      @index=true
     
     threads=Message.find_by_sql ['select "subject" from messages where '+appr_text+' "toUser_id" is null and subject is not null and forum_id = ? group by "subject" order by max(created_at) desc',  @id]


     thisItem=0
     @fullthreads=[]
     @counts=[]
    
     threads.each do |thread|
        @fullthreads[thisItem]=[]
        last_id=Message.find_by_sql ['select max(id) as id from messages where ('+appr_text+' "subject"=? and "toUser_id" is null and forum_id = ?)', thread.subject, @id]
        last=Message.find_by_id(last_id)
        #get other party

        first_id=Message.find_by_sql ['select min(id) as id from messages where ('+appr_text+' "subject"=? and "toUser_id" is null and forum_id = ?)',  thread.subject, @id]
        first=Message.find_by_id(first_id)
        @fullthreads[thisItem][0]=first
        if (first.id!=last.id) then @fullthreads[thisItem][1]=last end
         msg=Message.find_by_sql ['select count(id) as id from messages where ('+appr_text+' "subject"=? and "toUser_id" is null and forum_id = ?)',  thread.subject, @id] 
        @counts[thisItem]=msg.first.id
        thisItem+=1
     end

     @threads=@fullthreads.paginate(:per_page => 20, :page => params[:page])
     @edit=true
     if !@message then 
       @message=Message.new() 
       @message.forum_id=@id
     end
     render 'show'
   end

end

def show_thread

   if signed_in? and @current_user.role_id>1 then appr_text="" else appr_text="approved=true and " end
        @edit=true
        @messages=Message.find_by_sql [%q[select * from messages where (]+appr_text+%q["subject"=? and "toUser_id" is null and forum_id = ?)  order by created_at], @subject, @id]
   if !@message then 
     @message=Message.new() 
     if @messages and @messages.count>0 then
       @message.subject=@messages.last.subject
       @message.forum_id=@id
     end
   end
   @hide_to=true
   render 'show_thread'
end



def update
   @edit=true
   @message=Message.new(message_params)
   @message.approved=false
   if signed_in?
     @message.fromUser_id=@current_user.id
     @message.fromName=@current_user.name
     @message.fromEmail=@current_user.email
     @message.approved=true
   end

   errr=false

   if @message.approved==false then
      auth=@message.checkAuth
      case auth
      when "error"
        flash[:error] = "This name has been used with a different email (or the email has been used with a different name)"
        errr=true
      when "true"
        @message.approved=true
      when "suspended"
        flash[:error] = "Account suspended"
        errr=true
      else
        @message.save
        if @message.fromEmail  and @message.fromEmail.length>0
          authlist=Authlist.create_or_replace(:address => @message.fromEmail, :name => @message.fromName, :allow => false, :forbid => false)
          if authlist
             authlist.send_auth_email
             flash[:info] = "Check your mail and authenticate your address"
           #  flash[:success] = "Comment submitted to moderator for approval."
          else
            @message.approved=false
            flash[:success] = "Address validation failed. Message submitted to moderator for approval."
          end
        else
          @message.approved=false
          flash[:success] = "Message submitted to moderator for approval."
# Providing your email address will avoid this step"
        end
      end
   end

   if @message  and errr == false
     @id=@message.forum_id
     @subject=@message.subject
     if @message.save
       if @message.forum_id then
         @message=Message.new
         show()
       else
         @message=Message.new
         index()
       end
     else
       @messages=Message.where(:toUser_id=>@current_user.id)
       @edit=true
       if @message.forum_id then
         render 'show'
       else
         render 'index'
       end
     end
   else
     puts "failed"
     @id=@message.forum_id
     @subject=@message.subject
     show_thread()
   end
  end

def approve
    if (signed_in? and @current_user.role_id>1)
      message=Message.find_by_id(params[:selected_id])
      if message
         message.approved=true
         message.save
      end
    end

    @subject=params[:subject]
    @id=params[:id]
    show()

end


def destroy
    message=Message.find_by_id(params[:selected_id])
    if (signed_in? and (@current_user.role_id>1 or @current_user.id == message.fromUser_id))
      if message
         message.destroy
      end
    end

    @subject=params[:subject]
    @id=params[:id]
    show()
end

  private
  def message_params
    params.require(:message).permit(:subject, :toUser_id, :forum_id, :message, :fromName, :fromEmail)
  end

end
