require 'bundler'

Bundler.require :web
Bundler.require :development if development?

get '/style.css' do
  scss :style
end

get '/' do
  haml :index
end
