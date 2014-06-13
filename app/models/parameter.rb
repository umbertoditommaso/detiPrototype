class Parameter < ActiveRecord::Base
  attr_accessible :name,:spid
  belongs_to :telemetry
  validate :name,presence:true
  validate :spid,presence:true,numericaly:true
end
