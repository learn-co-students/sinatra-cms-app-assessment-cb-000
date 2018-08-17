class Helpers

  def self.current_user(session)
    if !session[:user].nil?
      user = User.find_by_id(session[:user_id])
      user
    end
  end

  def self.logged_in?(session)
    !!session[:user_id]
  end

end
