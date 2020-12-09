require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get '/' do
    @user = current_user if is_logged_in?
    erb :index
  end

  get '/signup' do
    if is_logged_in?
      redirect '/tweets'
    else
      erb :'/users/signup'
    end
  end

  post '/signup' do
    user = User.new(:username => params[:username], :email => params[:email], :password => params[:password])
    if user.save && user.username != "" && user.email != ""
      session[:user_id] = user.id
      redirect to "/tweets"
    else
      redirect '/signup'
    end
    redirect to "/tweets"
  end

  get '/login' do
    if is_logged_in?
      redirect '/tweets'
    else
      erb :'/users/login'
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
    end
    redirect '/tweets'
  end

  get "/users/:slug" do
    @user = User.find_by_slug(params[:slug])
    erb :'/users/show'
  end

  get '/logout' do
    session.clear
    redirect "/login"
  end


  post '/tweet' do
    if !params[:content].empty?
      tweet = Tweet.create(:content => params[:content])
      current_user.tweets << tweet
      current_user.save
      redirect '/tweets'
    else
      redirect to '/tweets/new'
    end
  end

  get '/tweets' do
    if is_logged_in?
      @user = current_user
      @tweets = Tweet.all
      erb :'/tweets/tweets'
    else
      redirect '/login'
    end
  end

  get '/tweets/new' do
    if is_logged_in?
      @user = current_user
      erb :'/tweets/create_tweet'
    else
      redirect to '/login'
    end
  end

  get '/tweets/:id' do
    if is_logged_in?
      @user = current_user
      @tweet = Tweet.find_by_id(params[:id])
      erb :'/tweets/show_tweet'
    else
      redirect to '/login'
    end
  end

  get '/tweets/:id/edit' do
    @tweet = Tweet.find_by_id(params[:id])
    if is_logged_in? && @tweet.user == current_user
      erb :'/tweets/edit_tweet'
    else
      redirect 'login'
    end
  end

  patch '/tweets/:id' do
    @tweet = Tweet.find_by_id(params[:id])
    if !params[:content].empty?
     @tweet.update(:content => params[:content])
     @tweet.save
     redirect "tweets/#{params[:id]}"
   else
     redirect "tweets/#{params[:id]}/edit"
   end
 end

 post '/tweets/:id/delete' do
   @tweet = Tweet.find_by_id(params[:id])
   if current_user == @tweet.user
      @tweet.delete
      redirect to '/tweets'
    else
      redirect to "/tweets/#{params[:id]}"
    end
  end



  helpers do
    def current_user
      User.find(session[:user_id])
    end

    def is_logged_in?
      !!session[:user_id]
    end
  end

end
