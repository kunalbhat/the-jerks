class Movie
  include DataMapper::Resource

  property :id            , Serial
  property :tmdb_id       , Integer
  property :title         , String
  property :director_name , String
  property :certification , String
  property :release_date  , Date
  property :runtime       , String
  property :j_seen_bool   , String
  property :e_seen_bool   , String
  property :r_seen_bool   , String
  property :k_seen_bool   , String
  property :s_seen_bool   , String
  property :removal_flag  , String
end

DataMapper.finalize
DataMapper.auto_upgrade!
