require 'pry'

class TweetController < ApplicationController

  get '/tweets' do
      @tweets = Tweet.all
      erb :'tweets/tweets'
  end

  get '/tweets/new' do
      erb :'tweets/create_tweet'
  end

  post '/tweets' do
    if params[:content].empty?
      redirect to "/tweets/new"
    else
      @tweet = current_user.tweets.create(content: params[:content])
      redirect to "/tweets/#{@tweet.id}"
    end
  end

  get '/tweets/:id' do
      @tweet = Tweet.find_by_id(params[:id])
      erb :'tweets/show_tweet'
  end

  get '/tweets/:id/edit' do
      @tweet = Tweet.find_by_id(params[:id])
      if @tweet.user_id == current_user.id
       erb :'tweets/edit_tweet'
      else
        redirect to '/tweets'
      end
  end

  post '/tweets/:id' do
    if params[:content].empty?
      redirect to "/tweets/#{params[:id]}/edit"
    else
      @tweet = Tweet.find_by_id(params[:id])
      @tweet.content = params[:content]
      @tweet.save
      redirect to "/tweets/#{@tweet.id}"
    end
  end

  delete '/tweets/:id/delete' do
      @tweet = Tweet.find_by_id(params[:id])
      @tweet.delete if @tweet.user_id == current_user.id
      redirect to '/tweets'
  end

end
