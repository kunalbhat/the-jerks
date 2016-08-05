require 'bundler/setup'
require 'rest_client'
require 'json'

Bundler.require :web
Bundler.require :development if development?
also_reload '/services/movie_info'
Dotenv.load

require_relative 'config/datamapper'
require_relative 'models/movie'
require_relative 'models/user'
require_relative 'models/proposal'
require_relative 'services/movie_info'

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
  haml :index
end

get '/list' do
  @movies = Movie.all

  haml :list
end

get '/proposals' do
  haml :"proposals/index"
end

get '/proposals/new/:id' do
  @movie = MovieInfo.new(params[:id])

  haml :"proposals/new"
end

get '/search' do
  query           = params[:q]
  results         = search_movie(query)
  @search_results = []

  results['results'].each do |result|
    @search_results.push(result)
  end

  haml :search
end

get '/movie/:id' do
  @movie = MovieInfo.new(params[:id])

  haml :movie
end
