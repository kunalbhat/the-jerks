require 'bundler/setup'
require 'csv'
require 'rest_client'
require 'json'

Bundler.require :web
Bundler.require :development if development?
Dotenv.load

# Configure Sass
get '/style.css' do
  scss :stylesheet, :style => :expanded
end

# Search TMDB for a movie, return results
def get_result(title)
  @title = title

  headers = {
    :content_type => 'json',
    :accept => 'json',
    :api_key => ENV['TMDB_API_KEY'],
    :query => @title
  }

  response = RestClient.get "http://api.themoviedb.org/3/search/movie", {:params => headers }

  json_response = JSON.parse(response)

  return json_response
end

def read_csv_into_array
  csv_titles = []

  CSV.foreach("list.csv", :headers => true) do |row|
    hash = { title: row[1], year: row[0] }
    csv_titles.push(hash)
  end

  return csv_titles
end

get '/' do
  titles = read_csv_into_array
  @films = []

  titles[1..5].each do |title|
    year = title[:year]
    title = title[:title]

    results = get_result(title)

    results['results'].each do |result|
      hash = { title: result['title'], year: result['release_date'], id: result['id'] }

      if result['release_date'].include? year
        @films.push(hash)
      end
    end
  end

  haml :index
end
