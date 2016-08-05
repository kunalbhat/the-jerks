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

# Define Sass
get '/stylesheet.css' do
  scss :stylesheet, :style => :expanded
end

# Check configuration endpoint
# TODO: Need to cache this data and perodically check for updates (days)
def configuration
  headers = {
    accept:   'application/json',
    api_key:  ENV['TMDB_API_KEY']
  }

  response      = RestClient.get "https://api.themoviedb.org/3/configuration", { params: headers }
  json_response = JSON.parse(response)

  return json_response
end

def build_image_url(poster_size, poster_path)
  config_data = configuration
  base_url    = config_data['images']['base_url']
  image_url   = "#{base_url}#{poster_size}#{poster_path}"

  return image_url
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

def get_movie_by_id(id)
  headers = {
    accept:              'application/json',
    api_key:             ENV['TMDB_API_KEY'],
    append_to_response:  'release_dates'
  }

  response      = RestClient.get "https://api.themoviedb.org/3/movie/#{id}", { params: headers }
  json_response = JSON.parse(response)

  return json_response
end

get '/' do
  haml :index
end

get '/list' do
  @films = Post.all

  haml :list
end

get '/proposals' do
  haml :"proposals/index"
end

get '/proposals/new/:id' do
  id = params[:id]

  @film = get_movie_by_id(id)

  puts @film

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
  id        = params[:id]
  film_data = get_movie_by_id(id)

  # Get poster
  poster_size = 'w185'
  poster_path = film_data['poster_path']
  image_url   = build_image_url(poster_size, poster_path)

  # Get film details
  title         = film_data['title']
  overview      = film_data['overview']
  year          = DateTime.parse(film_data['release_date']).year

  @film_data = { id: id, title: title, overview: overview, year: year, image_url: image_url }

  haml :movie
end
