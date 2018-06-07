class UserController < ApplicationController
  get '/signup' do
    @trying = 1
    if !logged_in?
      erb :'users/create_user'
    else
      redirect to '/hacks'
    end
  end

  post '/signup' do
    if params[:username].empty? || params[:email].empty? || params[:password].empty? #Remember empty strings are TRUE, can't use '!'
      redirect to '/signup'
    else
      @user = User.new(:username => params[:username], :email => params[:email], :password => params[:password])
      @user.save
      session[:user_id] = @user.id
      redirect to '/hacks'
    end
  end

  get '/login' do
    @trying = 1
    if !logged_in?
      erb :'users/login'
    else
      redirect '/hacks'
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/hacks"
    else
      redirect to '/signup'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end

  get '/logout' do
    if logged_in?
      session.clear
      redirect to '/login'
    else
      redirect to '/'
    end
  end
end
