require 'bundler'

Bundler.require

require_relative 'config/datamapper'

get '/' do
  haml :index, :format => :html5
end

