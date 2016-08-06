require_relative '../config/datamapper'

class Proposal
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :tmdb_id, Integer
  property :username, String, :length => 1
  property :proposal_text, Text
  property :date, DateTime
  property :j_vote, Boolean, :default => false
  property :e_vote, Boolean, :default => false
  property :r_vote, Boolean, :default => false
  property :k_vote, Boolean, :default => false
  property :s_vote, Boolean, :default => false
end

DataMapper.finalize
DataMapper.auto_upgrade!
