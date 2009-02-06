#! /usr/bin/ruby -w

arff_file = File.open('data/adult.arff', 'r')
relation_name = nil
attributes = Hash.new()

while line = arff_file.gets

	if line[0] == '%' then 
		# ignore since its a comment
	elsif line =~ /@RELATION/ then
		relation_name = line[10..-1]
	elsif line =~ /@ATTRIBUTE/ then
		line = line.split(' ', 2)
		puts line
		attributes[line[1]] = line[2]
	end


end

puts relation_name
puts attributes.to_a
