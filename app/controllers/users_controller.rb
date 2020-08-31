class UsersController < ApplicationController

  get '/users' do
    if logged_in?
      @users = User.all
      erb :'users/index'
    else
      erb :'users/login'
    end
  end

  get '/login' do
    if logged_in?
     redirect :"/books"
   else
     erb :'/users/login'
   end
  end

  post '/login' do
    if params[:username].empty? || params[:password].empty?
      flash[:message] = "Username and password are required to sign in. Try again."
      erb :'/users/login'
    else
      @user = User.find_by(username: params[:username])
      if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect :'/books'
      else
        session.clear
        flash[:message] = "Account not found. Please try again"
        erb :'/users/login'
      end
    end
  end

  get '/signup' do
    if logged_in?
      redirect :'/books/books'
    else
      erb :'/users/create_user'
    end
  end

  post '/signup' do

    if params[:username].empty? || params[:email].empty? || params[:password].empty?
      flash[:message] = "All fields are required to sign up.  Please try again."
      redirect :'/signup'
    elsif User.find_by(username: params[:username])
      flash[:message] = "Username already taken.  Please try another username."
      redirect :"/signup"
    elsif User.find_by(email: params[:email])
      flash[:message] = "An account already exists with this email.  Please use another email."
      redirect :'/signup'
    else
      @user = User.create(params)
      session[:user_id] = @user.id
      redirect :'/books'
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
      flash[:message] = "Successfully logged out."
      redirect :'/login'
    else
      redirect :'/'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    if @user
      erb :'/users/show'
    else
      erb :'not_found'
    end
  end

end
