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

get '/movie/:id' do
  id          = params[:id]
  film_data   = get_movie_by_id(id)

  # Get poster
  poster_size = 'w342'
  poster_path = film_data['poster_path']
  image_url   = build_image_url(poster_size, poster_path)

  # Get film details
  title         = film_data['title']
  overview      = film_data['overview']
  year          = DateTime.parse(film_data['release_date']).year

  p film_data

  @film_data = { title: title, overview: overview, year: year, image_url: image_url }

  haml :movie
end
