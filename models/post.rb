class Post
  include DataMapper::Resource

  property :id            , Serial
  property :tmdb_id       , Integer
  property :title         , String
  property :director_name , String
  property :release_date  , Date
  property :runtime       , Integer
  property :j_seen_bool   , Boolean
  property :e_seen_bool   , Boolean
  property :r_seen_bool   , Boolean
  property :k_seen_bool   , Boolean
  property :s_seen_bool   , Boolean
  property :removal_flag  , Boolean

  DataMapper.auto_migrate!
  DataMapper.finalize.auto_upgrade!
end
