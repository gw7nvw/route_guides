class MessagesController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]
 before_action :touch_user

def index

   @index=true
   if signed_in? then
   userPairs=Message.find_by_sql ['select "fromUser_id", "toUser_id"  from messages where ("fromUser_id"=?  or "toUser_id"=?) and "toUser_id" is not null group by "fromUser_id", "toUser_id" order by max(created_at) desc', @current_user.id.to_s, @current_user.id.to_s]

#get unique user pairs
   users=[]
   count=0
   userPairs.each do |up|
     if up.fromUser_id==@current_user.id then usr=up.toUser_id else usr=up.fromUser_id end
     if !(users.include? usr) then 
       users[count]=usr
       count+=1
     end
   end

     thisItem=0
     @threads=[]
     @counts=[]
    
     users.each do |user|
        @threads[thisItem]=[]
        last_id=Message.find_by_sql ['select max(id) as id from messages where ("fromUser_id"=? and "toUser_id"=?) or ("toUser_id"=? and "fromUser_id"=?)', @current_user.id.to_s, user.to_s, @current_user.id.to_s, user.to_s]
        last=Message.find_by_id(last_id)
        #get other party
        if (last.toUser_id==@current_user.id) then otherUser=last.fromUser_id else otherUser=last.toUser_id end

        first_id=Message.find_by_sql ['select min(id) as id from messages where ("fromUser_id"=? and "toUser_id"=?) or ("toUser_id"=? and "fromUser_id"=?)', @current_user.id.to_s, otherUser.to_s, @current_user.id.to_s, otherUser.to_s]
        first=Message.find_by_id(first_id)
        @threads[thisItem][0]=first
        if (first.id!=last.id) then @threads[thisItem][1]=last end
         msg=Message.find_by_sql ['select count(id) as id from messages where ("fromUser_id"=? and "toUser_id"=?) or ("toUser_id"=? and "fromUser_id"=?)', @current_user.id.to_s, otherUser.to_s, @current_user.id.to_s, otherUser.to_s] 
        @counts[thisItem]={:id => msg.first.id, :otherUser_id => otherUser}

        thisItem+=1

      end 

     @edit=true
   else
     @threads=[]
   end
   @message=Message.new() 
   @threads=@threads.paginate(:per_page => 20, :page => params[:page])

end

def show

   if signed_in? then
        @edit=true
        @messages=Message.find_by_sql ['select * from messages where ("fromUser_id"=? and "toUser_id"=?) or ("toUser_id"=? and "fromUser_id"=?) order by created_at', @current_user.id.to_s, params[:id], @current_user.id.to_s, params[:id]]
        @messages.each do |mess|
          if mess.hasBeenRead==nil then
            mess.hasBeenRead=true
            logger.debug "new mail read"
            mess.save
          end
        end
   end
   @message=Message.new() 
   if @messages and @messages.count>0 then
     if @messages.first.toUser_id==@current_user.id then  @message.toUser_id=@messages.first.fromUser_id 
     else  @message.toUser_id=@messages.first.toUser_id end
     @hide_to=true 
     @message.subject=@messages.last.subject
   end

   @messages=@messages.reverse.paginate(:per_page => 20, :page => params[:page])
end



def update
   @edit=true
   @message=Message.new(message_params)
   puts @message
   puts message_params
   @message.fromUser_id=@current_user.id
   @message.fromName=@current_user.name
   if @message.save
       index()
       render 'index'
   else
        @messages=Message.where(:toUser_id=>@current_user.id)
        @edit=true
       render 'index'
   end

end


  private
  def message_params
    params.require(:message).permit(:subject, :toUser_id, :forum_id, :message)
  end

end
