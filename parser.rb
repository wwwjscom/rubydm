#!/usr/local/bin/ruby -w

def this_thing
	@final = Hash.new()

	#class_name = @attributes.keys[@attributes.length-1]
	class_name = @attributes.last['name']
	class_vals = @attributes.last['val']
	puts class_name
	#class_count = @attributes[class_name].size

#	for i in (0..class_count) do
#		this_class_name = @attributes[class_name][i]
#		puts @attributes[class_name].key(i)
#		#puts this_class_name
#		puts i
#	end

	class_vals.each do |key, val|
		@final[key] = @attributes
	end

end

arff_file = File.open('data/adult.arff', 'r')
relation_name = nil
@attributes = Array.new()
@missing_values = Array.new()
@types = Array.new

j = 0
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
			@types.push('cat')
		else
			puts attr_name
			attr_val = 0
			@types.push('num')
		end

		#@attributes[attr_name] = attr_val
		val = Hash['name' => attr_name, 'val' => attr_val]
		@attributes.push(val)

	elsif line =~ /@DATA/ then

		# do nothing
		this_thing()
		
	elsif line != "" then

		# got data

		# check to see if the line has an unknown value
		if line.index('?') != nil then
			@missing_values.push(line)
			next
		end

		# entry has all values, lets process it
		line = line.split(', ')
		clas = line[line.length-1]


		for i in (0..line.size) do
			# figure out the type and do the appropriate thing
			puts @types[i]
			if @types[i] == 'num' then
				# avg the data
				puts "Name:(#{i}) ",@final[clas][i]['name']
				puts "Used to be: #{@final[clas][i]}"
				@final[clas][i] = line[i]
				puts "Now its: #{@final[clas][i]}"
			end
		end
	end

	# debug block
	if j > 25 then
		break
	end
	j += 1
end

@attributes.each do |key, val|
	#puts "#{key} => #{val}"
end


	@final.each do |key, val|
		puts "#{key} => #{val}"
		puts '-'*50
	end

puts @types
puts @attributes
