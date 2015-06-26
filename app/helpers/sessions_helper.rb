module SessionsHelper

  def sign_in(user)
    remember_token = User.new_token
    cookies[:remember_token] = {value: remember_token, expires: 1.month.from_now.utc}
    user.update_attribute(:remember_token, User.digest(remember_token))
    self.current_user = user
  end

  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.digest(User.new_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def create_guest
    remember_token=Guest.new_token
    cookies[:remember_token] = {value: remember_token, expires: 1.month.from_now.utc}
    trip=Trip.create(:name => "My Trip")
    digest=Guest.digest(cookies[:remember_token])
    guest=Guest.create(:remember_token => digest, :currenttrip_id => trip.id)
    self.current_guest=guest
    tidy_guests()
  end


  def tidy_guests
    guests=Guest.find_by_sql [ " select * from guests where created_at < ? ", (Date.today-90).strftime('%F')
]
    guests.each do |g|
       g.destroy
    end

    trips=Trip.find_by_sql [ ' select * from trips where "createdBy_id" is null and created_at < ? ', (Date.today-90).strftime('%F') ]
    trips.each do |t|
       t.destroy_tree
    end
  end

  def signed_in?
    !current_user.nil?
  end

  def is_guest?
    !current_guest.nil?
  end

  def current_guest=(guest)
    @current_guest = guest
  end
 
  def current_guest
    remember_token = Guest.digest(cookies[:remember_token])
    @current_guest ||= Guest.find_by(remember_token: remember_token)
  end

  def forget_guest
    current_guest.update_attribute(:remember_token,
                                  Guest.digest(Guest.new_token))
    cookies.delete(:remember_token)
    @current_guest.currenttrip.destroy
    @current_guest.destroy
    self.current_guest = nil
    
  end


  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.digest(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end
end
