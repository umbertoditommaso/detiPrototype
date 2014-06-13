class Database < ActiveRecord::Base
  attr_accessible :mission, :version,:active
  has_many :telemetries,:dependent => :destroy
  validate :mission,presence:true,format:{with:/[^\/\\\"\']+/}
  validate :version,presence:true,format:{with:/[^\/\\\"\']+/}
  
  #return the database's folder relative path
  def path
    return "telemetries/#{mission}/#{version}"
  end

  #return the relative path of the SCOSS_input.db file
  def scoss
    return self.path+"/SCOSS_input.db"
  end


  #set the database as active if exists the required files in the database folder
  def activate
    files = ["Firme.txt","SCOSS_input.db"]
    puts "[DATABASE_ACTIVATE]required files\n"
    puts files
    files = files.map{|file| path+"/#{file}"}
    files.each do |f|
      if !File.exists? f then
        return nil
      end
    end
    self.active= true
    self.save
    return self 
  end

  
  #import the telemetries contained in the database folder
  # => create a telemetry folder for each one and its structure
  # => move the telemetry files to each folder
  # => move the telemetries in the input subfolder in folder named as the current timestamp
  def importTelemetries
    files = Dir.entries(path)
    files.delete_if {|f| !f.include? ".good"}
      
    files.each do |file|
      dir_name = "#{path}/#{file}"
      dir_name[".good"]="_#{self.version}" 
      puts dir_name
      name = file.clone
      name[".good"] = ""
      puts name
      self.telemetries.create(name: name) unless self.telemetries.exists?(:name=>name)
      if !Dir.exists? dir_name then  
        Dir.mkdir dir_name
        Dir.mkdir "#{dir_name}/VC"
        Dir.mkdir "#{dir_name}/Logs"
        Dir.mkdir "#{dir_name}/Synthetic"
        Dir.mkdir "#{dir_name}/Parameters"
        Dir.mkdir "#{dir_name}/Packets"
      end
      File.rename("#{path}/#{file}","#{dir_name}/#{file}")
    end
    Dir.mkdir "#{path}/processed" unless Dir.exists? "#{path}/processed"
    File.rename("#{path}/input","#{path}/processed/#{Time.now.to_i}")
    Dir.mkdir("#{path}/input")
    self.save
    return self.telemetries
  end

end
