class Lock < ActiveRecord::Base
  attr_accessible :mode, :resource
  belongs_to :task
  validate :resource,presence:true

  def self.acquire(resource,mode)
    @lock = Lock.new
    @lock.resource = parse_dir (resource)
  	@lock.resource = resource
  	@lock.mode= mode
    @mode = mode
  	@exist = Lock.where(['resource = ?', resource])
    puts "[Lock]Requested: #{@lock.resource}"
  	if !@exist.empty? then
  		if @mode == 'r' and @exist.any?{ |lock| lock.mode=='w'} then
        puts "[LOCK]ERROR 16"
  			return nil
  		end

  		if @mode == 'w'
        puts "[LOCK]ERROR 21"
  			return nil
  		end

  		#if @mode = 'x'
  		#	return nil
  		#end
  		
  	end
    puts "[LOCK]acquired"
  	return @lock	
  end

protected
  def self.parse_dir(path)
    @path = path
    if @path.include?".." then
      a = @path.lines('/').to_a
      i = a.index("../")
      a[i] = ""
      a[i-1]=""
      @path = a.join
    end
    return @path 
  end

end
