require 'bundler/setup'

Bundler.require :web
Bundler.require :development if development?

get '/style.css' do
  scss :stylesheet, :style => :expanded
end

get '/' do
  haml :index
end
