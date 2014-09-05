class ForumsController < ApplicationController
 before_action :signed_in_user, only: [:edit, :update, :new, :create]
 before_action :touch_user

def index
   @id=1
   show()
   render 'show'
end


def show
   if !@id then @id=params[:id].to_i end
   if !@subject then @subject=params[:thread] end
   if @subject then 
      show_thread()
   else
      @index=true
     threads=Message.find_by_sql ['select "subject" from messages where "toUser_id" is null  and subject is not null and forum_id = ? group by "subject"', @id]

     thisItem=0
     @threads=[]
     @counts=[]
    
     threads.each do |thread|
        @threads[thisItem]=[]
        last_id=Message.find_by_sql ['select max(id) as id from messages where ("subject"=? and "toUser_id" is null and forum_id = ?)', thread.subject, @id]
        last=Message.find_by_id(last_id)
        #get other party

        first_id=Message.find_by_sql ['select min(id) as id from messages where ("subject"=? and "toUser_id" is null and forum_id = ?)', thread.subject, @id]
        first=Message.find_by_id(first_id)
        @threads[thisItem][0]=first
        if (first.id!=last.id) then @threads[thisItem][1]=last end
         msg=Message.find_by_sql ['select count(id) as id from messages where ("subject"=? and "toUser_id" is null and forum_id = ?)', thread.subject, @id] 
        @counts[thisItem]=msg.first.id
        thisItem+=1
     end


     @edit=true
     @message=Message.new() 
     @message.forum_id=@id
   end
end

def show_thread

   if signed_in? then
        @edit=true
   end
        @messages=Message.find_by_sql [%q[select * from messages where ("subject"=? and "toUser_id" is null and forum_id = ?)  order by created_at], @subject, @id]
   @message=Message.new() 
   if @messages and @messages.count>0 then
     @message.subject=@messages.last.subject
     @message.forum_id=@id
   end
   render 'show_thread'
end



def update
   @edit=true
   @message=Message.new(message_params)

   @message.fromUser_id=@current_user.id
   if @message.save
     if @message.forum_id then 
       @id=@message.forum_id
       @subject=@message.subject
       show()
     else 
       index()
     end
   else
       @messages=Message.where(:forum_id=>@message.forum_id)
       @forum=true
       @edit=true
       render 'show'
   end

end


  private
  def message_params
    params.require(:message).permit(:subject, :toUser_id, :forum_id, :message)
  end

end
