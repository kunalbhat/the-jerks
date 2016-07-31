require 'bundler/setup'

Bundler.require :web
Bundler.require :development if development?
Dotenv.load

require_relative 'config/tmdb'

get '/style.css' do
  scss :stylesheet, :style => :expanded
end

get '/' do
  haml :index
end

url = "#{@tmdb_api_base_url}movie/550?api_key=#{ENV['TMDB_API_KEY']}"

p url
