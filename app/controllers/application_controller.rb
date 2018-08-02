require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get '/' do
    @trying = 1
    erb :index
  end

  helpers do
    def logged_in?
      !!current_user
    end

    def current_user
      #More code, but only a single database access this way.
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
  end

end
