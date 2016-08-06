require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest_client'
require 'active_record'

Bundler.require :web
Bundler.require :development if development?
Dotenv.load if development?

require_relative 'config/datamapper'
require_relative 'models/movie'
require_relative 'models/user'
require_relative 'models/proposal'
require_relative 'services/movie_info'

Warden::Strategies.add(:password) do
  def valid?
    params['user'] && params['user']['username'] && params['user']['password']
  end

  def authenticate!
    user = User.first(username: params['user']['username'])

    if user.nil?
      throw(:warden, message: "The username you entered does not exist.")
    elsif user.authenticate(params['user']['password'])
      success!(user)
    else
      throw(:warden, message: "The username and password combination ")
    end
  end
end

class TheJerksApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.get(id) }

    config.scope_defaults :default,
      strategies: [:password],
      action: 'auth/unauthenticated'
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
    env.each do |key, value|
      env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
    end
  end

  configure do
    set :haml, :layout => :'layouts/default'
  end

  # Define Sass
  get '/stylesheet.css' do
    scss :stylesheet, :style => :expanded
  end

  # Search TMDB for a movie, return results
  def search_movie(title)
    headers = {
      accept:        'application/json',
      api_key:       ENV['TMDB_API_KEY'],
      content_type:  'json',
      query:         title,
    }

    response      = RestClient.get "https://api.themoviedb.org/3/search/movie/", { params: headers }
    json_response = JSON.parse(response)

    return json_response
  end

  get '/' do
    env['warden'].authenticate!

    @movies = Movie.all

    haml :index
  end

  get '/auth/login' do
    haml :"auth/login", layout: :'layouts/blank'
  end

  post '/auth/login' do
    env['warden'].authenticate!

    flash[:success] = "Successfully logged in"

    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end

  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?

    # Set the error and use a fallback if the message is not defined
    flash[:error] = env['warden.options'][:message] || "You must log in"
    redirect '/auth/login'
  end

  get '/proposals' do
    env['warden'].authenticate!

    proposals = Proposal.all
    @proposals = []

    proposals.each do |proposal|
      @proposals.push({ proposal: proposal, movie: MovieInfo.new(proposal.tmdb_id) })
    end

    haml :"proposals/index"
  end

  get '/proposals/new/:id' do
    env['warden'].authenticate!

    if defined? params[:id]
      @movie = MovieInfo.new(params[:id])
    end

    haml :"proposals/new"
  end

  post '/proposals/new' do
    env['warden'].authenticate!

    tmdb_id  = params[:tmdb_id]
    body     = params[:body]
    username = params[:username]
    date     = Time.now

    @proposal = Proposal.new(tmdb_id: tmdb_id, proposal_text: body, username: username, date: date)
    @proposal.save

    redirect '/proposals'
  end

  get '/search' do
    env['warden'].authenticate!

    query           = params[:q]
    results         = search_movie(query)
    @search_results = []

    results['results'].each do |result|
      @search_results.push(result)
    end

    haml :search
  end

  get '/movie/:id' do
    env['warden'].authenticate!

    @movie = MovieInfo.new(params[:id])

    haml :movie
  end
end
