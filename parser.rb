#!/usr/local/bin/ruby -w

def this_thing
	final = Hash.new()

	class_name = @attributes.keys[@attributes.length-1]
	@attributes[class_name].each do |key, val|
		final[key] = @attributes
	end

	final.each do |key, val|
		puts "#{key} => #{val}"
		puts '-'*50
	end
end

arff_file = File.open('data/adult.arff', 'r')
relation_name = nil
@attributes = Hash.new()

i = 0
while line = arff_file.gets.chomp!

	if line[0] == '%' then 

		# ignore since its a comment
		
	elsif line =~ /@RELATION/ then

		relation_name = line[10..-1]

	elsif line =~ /@ATTRIBUTE/ then

		line = line[11..-1] # chop off the @ATTRIBUTE tag
		line = line.split(/\t+| /, 2)

		attr_name = line[0]
		attr_val = line[1]

		if attr_val[0] == '{' then
			# split up the list of @attributes
			
			attr_val[attr_val.index('{')] = ''
			attr_val[attr_val.index('}')] = ''

			attr_val = attr_val.split(',')

			# turns the values into a hash so we can count the occurances
			values = Hash.new()
			attr_val.each do |_attr|
				values[_attr] = 0
			end

			attr_val = values
		else
			attr_val = 0
		end

		@attributes[attr_name] = attr_val

	elsif line =~ /@DATA/ then

		# do nothing
		this_thing()
		
	elsif line != "" then

		line = line.split(',')
		clas = line[line.length-1]

		@attributes[clas] = line
	end

	# debug block
	if i > 25 then
		break
	end
	i += 1
end

@attributes.each do |key, val|
	#puts "#{key} => #{val}"
end


