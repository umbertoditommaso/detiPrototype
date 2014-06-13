class Packet < ActiveRecord::Base
  attr_accessible :spid,:channel
  has_many :parameters
  belongs_to :telemetry
  validate :spid,presence:true,numericaly:true
  validate :channel,presence:true,numericaly:true
end
