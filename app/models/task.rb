require 'nokogiri'

class Task < ActiveRecord::Base
  attr_accessible :name_id,:exec,:arguments,:path,:settings,:pid
  serialize :settings
  class_attribute :inputs,:description,:label
  validate :name_id,presence:true,format:{with:/[^\/\\"']+/}
  validate :exec,presence:true
  validate :path,presence:true
  has_many :locks,dependent: :destroy

  #return the comand that the task will  try to execute
  # => es. Process.spawn(task.getCmd(Dir.pwd))
  def getCmd(root)
  	return "\"#{root}/proc/bin/"+exec+"\" #{arguments} > \"#{self.getStdout}\""
  end

  #return the .xml manifest of the process
  # =>  es: f = File.open(task.getManifest)
  def getManifest
  	return "proc/#{name_id}.xml"
  end

  #return the location of the standard output of the task object
  # => es: task.getStdout
  def getStdout
  	return "#{path}#{exec}_#{id}.out.txt"
  end

  def acquire_locks
    Lock.transaction do
      #open the task manifest
      f = File.open(self.getManifest)
      #parse using Nokigiri gem
      doc = Nokogiri::XML(f)
      doc.xpath("//inputs//files").each do |entry|
        lock = Lock.acquire( self.path+entry.content,'r')
        raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
        self.locks << lock
        
      end
      doc.xpath("//output//files").each do |entry| 
        lock = Lock.acquire(self.path+entry.content,'w')
        raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
        self.locks << lock
        
      end
      f.close
      self.save!
     end
  end

  #Create a Task object from the given name .xml file in the proc/ directory
  # =>  example usage: self = Task.build("packetfinder")
  def self.build(task_name)
      task = Task.new
      task.name_id = task_name
      f = File.open("proc/#{task_name}.xml")
      doc = Nokogiri::XML(f)
      #task.exec = doc.at_css("executable name").content
      task.arguments =""
      task.inputs = {}
      task.settings={}
      doc.xpath("//setting").each do |row|
        task.settings[row.content]=nil
      end
      res = doc.xpath("//in//param").each  do |row|
        task.inputs[row.at_xpath("name").content] = row.at_xpath("defaults").content
      end
      task.label = doc.at_css("function name").content
      task.description = doc.at_css("description").content
      #task.path = Dir.pwd+doc.at_css("workingDir").content
      res = doc.xpath("//defaults").each do |row|
        task.arguments << " "+ row.content
      end
      f.close
      return task
  end
  
  

end
