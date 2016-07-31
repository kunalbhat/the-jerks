require 'bundler/setup'
require 'csv'
require 'rest_client'
require 'json'

Bundler.require :web
Bundler.require :development if development?
Dotenv.load

require_relative('config/datamapper')

# Configure Sass
get '/style.css' do
  scss :stylesheet, :style => :expanded
end

# Search TMDB for a movie, return results
def get_result(title)
  @title = title

  headers = {
    content_type: 'json',
    accept: 'json',
    api_key: ENV['TMDB_API_KEY'],
    query: @title
  }

  response = RestClient.get "http://api.themoviedb.org/3/search/movie/", { :params => headers }

  json_response = JSON.parse(response)

  return json_response
end

def get_film_crew(id)
  @id = id

  headers = {
    api_key: ENV['TMDB_API_KEY']
  }

  response = RestClient.get "http://api.themoviedb.org/3/movie/#{@id}/credits", { params: headers }

  film = JSON.parse(response)

  film['crew'].each do |crew_member|
    return crew_member['name'] if crew_member['job'] == "Director"
  end
end

def get_film_details(id)
  @id = id

  headers = {
    content_type: 'json',
    accept: 'json',
    api_key: ENV['TMDB_API_KEY']
  }

  response = RestClient.get "http://api.themoviedb.org/3/movie/#{@id}", { params: headers }

  director = get_film_crew(@id)

  film = JSON.parse(response)
  hash = { title: film['title'], release_date: film['release_date'], director: director }

  film_details = hash

  return film_details
end

def read_csv_into_array
  csv_titles = []

  CSV.foreach("list.csv", :headers => true) do |row|
    hash = { title: row[1], year: row[0] }
    csv_titles.push(hash)
  end

  return csv_titles
end

def seed_db
  titles = read_csv_into_array
  films = []
  @films_db = []

  titles[1..5].each do |title|
    year = title[:year]
    title = title[:title]

    results = get_result(title)

    results['results'].each do |result|
      hash = { id: result['id'] }

      if result['release_date'].include? year
        films.push(hash)
      end
    end
  end

  films.each do |film|
    @films_db.push(get_film_details(film[:id]))
  end
end

get '/' do
  haml :index
end

def create_table

end

