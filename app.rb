require 'bundler'

Bundler.require :production
Bundler.require :development if development?

require_relative 'config/datamapper'

get '/' do
  haml :index, :format => :html5
end

