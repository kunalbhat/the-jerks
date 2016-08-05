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
