class Proposal
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :tmdb_id, Integer
  property :username, String, :length => 3..50
  property :proposal_text, Text
end

DataMapper.finalize
DataMapper.auto_upgrade!
