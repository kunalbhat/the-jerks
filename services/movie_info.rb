require 'date'
require_relative 'configuration'

class MovieInfo
  attr_accessor :id

  def initialize(id)
    self.id = id
  end

  def to_hash
    {
      id: id,
      title: title,
      release_date: release_date,
      director: director,
      certification: certification,
      overview: overview,
      poster_url: poster_url
    }
  end

  def get_movie_by_id
    headers = {
      accept:             'application/json',
      api_key:            ENV['TMDB_API_KEY'],
      append_to_response: 'release_dates, credits'
    }

    data         = RestClient.get "https://api.themoviedb.org/3/movie/#{id}", { params: headers }
    @_movie_info = JSON.parse(data)
  end

  def poster_url
    config_data = configuration
    base_url    = config_data['images']['base_url']
    poster_size = 'w342'
    poster_path = get_movie_by_id['poster_path']

    @_poster_url = "#{base_url}#{poster_size}#{poster_path}"
  end

  def title
    @_title = get_movie_by_id['title']
  end

  def release_date
    get_movie_by_id['release_date'].empty? ? nil : @_release_date = get_movie_by_id['release_date']
  end

  def release_dates
    @_release_dates = get_movie_by_id['release_dates']
  end

  def year
    release_date.nil? ? nil : @_year = DateTime.parse(release_date).year
  end

  def overview
    @_overview = get_movie_by_id['overview']
  end
end
