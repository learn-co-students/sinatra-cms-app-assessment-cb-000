class BooksController < ApplicationController

  get '/books' do
    if logged_in?
      @books = Book.all
      erb :index
    else
      flash[:message] = "You must be logged in to view the books directory."
      redirect :'/login'
    end
  end

  get '/books/new' do
    if logged_in?
      erb :'/books/create_book'
    else
      flash[:message] = "You must be logged in to create a new book."
      redirect :'/login'
    end
  end

  post '/books' do
    if params[:title].empty? || params[:author].empty? || params[:blurb].empty?
      flash[:message] = "Oops! It looks like you've left a field blank!"

      redirect :'/books/new'
    else
      @book = Book.create(params)
      @book.user_id = session[:user_id]
      @book.save

      flash[:message] = "Book created succesfully!"
      redirect :"books/#{@book.id}"
    end
  end

  get '/books/:id' do
    if logged_in?
      @book = Book.find_by_id(params[:id])
      erb :'/books/show_book'
    else
      flash[:message] = "You must be logged in to view the books directory."
      redirect :'/login'
    end
  end

  get '/books/:id/edit' do
    if logged_in?
      @book = Book.find(params[:id])
      if @book && session[:user_id] == @book.user_id
        erb :'/books/edit_book'
      else
        flash[:message] = "You must be the book creater in order to edit."
        redirect :'/books'
      end
    else
      flash[:message] = "You must be logged in to edit books."
      redirect :"/login"
    end
  end

  patch '/books/:id' do
    @book = Book.find_by_id(params[:id])

    if params[:title].empty? || params[:author].empty? || params[:blurb].empty?
      flash[:message] = "Oops! It looks like you've left a field blank!"
      redirect :"/books/#{@book.id}/edit"
    else
      @book.title = params[:title]
      @book.author = params[:author]
      @book.blurb = params[:blurb]
      @book.save
      flash[:message] = "You've succesfully edited your book!"
      redirect :"/book/#{@book.id}"
    end
  end

  #DELETE BOOKS
    post '/books/:id/delete' do
      if logged_in?
        @book = Book.find(params[:id])
        if @book && @book.user_id == session[:user_id]
          @book.delete
          flash[:message] = "You've successfully deleted your Book!"
          redirect :'/books'
        else
          flash[:message] = "You don't have permission to delete this book!."
          redirect :'/books'
        end
      else
        flash[:message] = "You must be logged in to delete a book!."
        redirect :'users/login'
      end
    end
end
