require 'sqlite3'

class Telemetry < ActiveRecord::Base
  attr_accessible :name
  has_many :virtual_channels,dependent: :destroy
  has_many :packets,dependent: :destroy
  has_many :parameters,dependent: :destroy
  belongs_to :database
  validate :name,presence:true,uniqueness:true,format:{with:/[^\/\\\"\']+/}

  def path
    return "#{database.path}/#{name}_#{database.version}"
  end
  

  def importChannels
    path = "#{self.path}/VC"
    files = Dir.entries(path)
    files.delete_if {|f| !f.include? "VC" and !f.include? ".bin"}   
    files.each do |file|
      channel = file.match(/[[:digit:]]/)[0]
      puts channel
      self.virtual_channels.create(channel: channel) unless self.virtual_channels.exists?(channel:channel)
    end
    self.save
  end
  
  def importPackets(channel)
    path = "#{self.path}/Packets"
    files = Dir.entries(path)
    files.delete_if {|f| f.include? "Fail" or !f.include? ".bin"}   
    files.each do |file|
      spid = file.slice(0,9)
      self.packets.create(:spid=>spid,:channel=>channel) unless self.packets.exists?(:spid=>spid)
    end
    self.save
  end

  def importParameters
    path = "#{self.path}/Parameters"
    files = Dir.entries(path)
    @date = self.name.clone.slice(9..-1)
    puts "[Telemetry][importParameters][43]importing parameters\n date:"+@date
    files.delete_if {|f| !f.include? ".csv" and !f.include? @date}
    @existings =[]
    self.parameters.each{|param| @existings << param.name}
    names = []
    #puts "existings:\n"
    #puts @existings
    puts files
    files.each {|f| s = f.slice (0..(f.index("_#{@date.first 4}")-1))
    puts "[Telemetry][importParameters][52]name:#{s}\n"
    names << s}
    #puts "importing:\n"
    #puts names
    #names.delete_if{ |name| @existings.include?name}
    puts "missings:\n"
    names -=@existings
    puts names
    begin
      db = SQLite3::Database.new self.database.scoss     
      #files.each do |file|
      #  param = file.slice(0,8)
      names.each do |param|
        if param.include?"IMU" then
          i =param.index("_")
          tdocc =  1000  / param.slice(3..i).to_i
          puts "tdocc:#{tdocc}\n"
          name = param.slice((i+1)..-1)
          puts "plf_name:#{name}"
          @rows = db.execute( "select plf_spid from plf where plf_name = ? and plf_tdocc = ?",name,tdocc)
        else
          @rows = db.execute( "select plf_spid from plf where plf_name = ?",param)
        end
        puts @rows
        spid = @rows.join
        puts "insert into parameters name:#{param} spid:#{spid}"
        #self.parameters.create(:name=>param,:spid=>spid) unless self.parameters.exists?(:name=>param,:spid=>spid)
        self.parameters.create(:name=>param,:spid=>spid)
      end
      self.save

      rescue SQLite3::Exception => e 
      puts "Exception occured"
      puts e
      ensure
          db.close if db
    end
    
  end

  def importAll(channel)
    self.importChannels
    self.importPackets(channel)
    self.importParameters
  end
end