class VirtualChannel < ActiveRecord::Base
  attr_accessible :channel
  has_many :packets
  belongs_to :telemetry
  validate :channel,presence:true,numericaly:true
  
  def path
  	return "#{telemetry.path}/VC"
  end


end
