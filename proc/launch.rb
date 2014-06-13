Dir.chdir ARGV[0]
puts ARGV[0]
puts Dir.pwd
#%x[#{ARGV[1]}]
exec(ARGV[1])