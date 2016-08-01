require 'bundler/setup'
require 'rest_client'
require 'json'

Bundler.require :web
Bundler.require :development if development?
Dotenv.load

# Configurations
require_relative 'config/datamapper'

# Models
require_relative 'models/post'

# Decorators
require_relative 'decorators/indicator_style'

# Define Sass
get '/stylesheet.css' do
  scss :stylesheet, :style => :expanded
end

# Search TMDB for a movie, return results
def search_movie(title)
  @title = title

  headers = {
    content_type:        'json',
    accept:              'json',
    api_key:             ENV['TMDB_API_KEY'],
    query:               @title,
    append_to_response:  'configuration'
  }

  response = RestClient.get "https://api.themoviedb.org/3/search/movie/", { :params => headers }

  json_response = JSON.parse(response)

  return json_response
end

get '/' do
  @films = Post.all

  haml :index
end

get '/proposals' do
  haml :proposals
end

get '/search' do
  content_type :json
  query = params[:query]

  @results = search_movie(query)

  { :data => @results }.to_json
end
