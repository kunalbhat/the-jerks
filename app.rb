require 'bundler/setup'
require 'csv'
require 'rest_client'
require 'json'

Bundler.require :web
Bundler.require :development if development?
Dotenv.load

# Configurations
require_relative('config/datamapper')

# Models
require_relative('models/post')

# Define Sass
get '/style.css' do
  scss :stylesheet, :style => :expanded
end

# Search TMDB for a movie, return results
def get_result(title)
  @title = title

  headers = {
    content_type:  'json',
    accept:        'json',
    api_key:       ENV['TMDB_API_KEY'],
    query:         @title
  }

  response = RestClient.get "http://api.themoviedb.org/3/search/movie/", { :params => headers }

  json_response = JSON.parse(response)

  return json_response
end

def get_film_details(id, j, e, r, k, s)
  headers = {
    content_type:        'json',
    accept:              'json',
    api_key:             ENV['TMDB_API_KEY'],
    append_to_response:  'releases,credits'
  }

  response = RestClient.get "http://api.themoviedb.org/3/movie/#{id}", { params: headers }
  film     = JSON.parse(response)

  # Get certifiation (MPAA rating) from Releases method
  film['releases']['countries'].each do |release|
    @certification = release['certification'] if release['iso_3166_1'] == "US"
  end

  # Get director from Cast method
  film['credits']['crew'].each do |crew_member|
    @director = crew_member['name'] if crew_member['job'] == "Director"
  end

  film_details = {
    tmdb_id:        id,
    title:          film['title'],
    director_name:  @director,
    certification:  @certification,
    release_date:   film['release_date'],
    runtime:        film['runtime'],
    j_seen_bool:    j,
    e_seen_bool:    e,
    r_seen_bool:    r,
    k_seen_bool:    k,
    s_seen_bool:    s,
    removal_flag:   'False'
  }

  return film_details
end

def read_csv_into_array
  csv_titles = []

  CSV.foreach("list.csv", :headers => true) do |row|
    hash = {
      title:  row[1],
      year:   row[0],
      j:      row[5],
      e:      row[6],
      r:      row[7],
      k:      row[8],
      s:      row[9]
    }

    csv_titles.push(hash)
  end

  return csv_titles
end

def seed_db
  titles    = read_csv_into_array
  films     = []
  @films_db = []

  titles[1..5].each do |title|
    year       = title[:year]
    j          = title[:j]
    e          = title[:e]
    r          = title[:r]
    k          = title[:k]
    s          = title[:s]
    film_title = title[:title]

    results = get_result(film_title)

    results['results'].each do |result|
      hash = {
        id: result['id'],
        j: j,
        e: e,
        r: r,
        k: k,
        s: s
      }

      if result['release_date'].include? year
        films.push(hash)
      end
    end
  end

  films.each do |film|
    @films_db.push(get_film_details(film[:id], film[:j], film[:e], film[:r], film[:k], film[:s]))
  end

  return @films_db
end

get '/' do
  @films = read_db

  haml :index
end

def connect_to_db
  DataMapper::Model.raise_on_save_failure = true
  films = seed_db

  films.each do |film|
    post = Post.create(tmdb_id: film[:tmdb_id], title: film[:title], director_name: film[:director_name], certification: film[:certification], release_date: film[:release_date], runtime: film[:runtime], j_seen_bool: film[:j_seen_bool], e_seen_bool: film[:e_seen_bool], r_seen_bool: film[:r_seen_bool], k_seen_bool: film[:k_seen_bool], s_seen_bool: film[:s_seen_bool], removal_flag: film[:removal_flag])
  end
end

# connect_to_db

def read_db
  return Post.all
end
