class Message < ActiveRecord::Base
  belongs_to :fromUser, class_name: "User"
  belongs_to :toUser, class_name: "User"
 
#  validates :fromUser, :presence => true
  validates :subject, :presence => true
  validates :message, :presence => true
  validates :fromName, :presence => true

  validates :fromEmail, format: { with: /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i }

def checkAuth
  authorised="false"
  if self.valid?
    #check if this email is used by another name.  Error if so
    notouremail=Authlist.find_by_sql [ "select * from authlists where address = ? and name <> ?", self.fromEmail, self.fromName ]
    usersname=User.where(:name => self.fromName)
    if notouremail.count>0 or usersname.count>0 then
      authorised="error"
    else
      authnames=Authlist.find_by_sql [ "select * from authlists where name = ?", self.fromName ]
        if authnames.count>0
        auth=authnames.first
        if !self.fromEmail or (self.fromEmail and auth.address != self.fromEmail)
           authorised="error"
        end

        if self.fromEmail and self.fromEmail.length>1 and auth.address == self.fromEmail
           if auth.allow==true then
             authorised="true"
           end
           if auth.forbid==true then
               authorised="suspended"
           end
        end
      end
    end
  else
    authorised="error"
  end
  authorised
end


  def downcase_fromEmail
      if(fromEmail.length<1) then fromEmail="anon@anon.net" end
      self.fromEmail = fromEmail.downcase
  end


end
