require 'Nokogiri'
root = Dir.pwd
f = File.open("proc/schedule.xml")
doc = Nokogiri::XML(f)
doc.xpath("//task").each do |task|
	path = task.at_xpath("//path").content
	arguments = task.at_xpath("//arguments").content
	exec = task.at_xpath("//exec").content
	id = task.at_xpath("//id").content
	stdout = "#{path}#{exec}_#{id}.out.txt"
	@cmd = "\"#{root}/proc/bin/"+exec+"\" #{arguments} > \"#{stdout}\""
	@job ="ruby proc/launch.rb #{path} \"#{@cmd}\""
	puts "[SCHEDULER]executing:#{@job}"
	res = system @job
	puts res
end