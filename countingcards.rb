require 'pathname'
require 'fileutils'

puts ARGV[0]
Dir[ARGV[0]].each do |folder|
	if Pathname.new(folder).directory?
		puts "Counting pdfs in #{folder}"
		count = 0
		Dir["#{folder}/**/*.pdf"].each do |fn|
			count = count + 1
		end
		puts "#{count} pdfs in #{folder}"
	end
end