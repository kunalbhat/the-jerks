require_relative '../config/datamapper'

class Proposal
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :tmdb_id, Integer
  property :username, String, :length => 1
  property :proposal_text, Text
  property :date, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!
