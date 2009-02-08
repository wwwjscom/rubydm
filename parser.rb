#!/usr/local/bin/ruby -w

@final = Hash.new()
class Foo

	# returns a hash of the classes
	def find_classes

		@types = Array.new
		@attributes = Array.new()
		@attributes2 = Array.new()
		@final = Hash.new()

		arff_file = File.open('data/adult.arff', 'r')

		while line = arff_file.gets.chomp!

			if line[0] == '%' then 

				# ignore since its a comment

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
					attr_val = 0
					@types.push('num')
				end

				#@attributes[attr_name] = attr_val
				val = Hash['name' => attr_name, 'val' => attr_val]
				val2 = Hash['name' => attr_name, 'val' => attr_val]
				@attributes.push(val)
				@attributes2.push(val2)

				@final.each do |entry|
					entry.push(Hash['name' => attr_name, 'val' => attr_val])
				end

			elsif line =~ /@DATA/ then

				# do nothing
				return @attributes.last['val']

			end
		end
	end

end

def this_thing

	#@final = Hash.new()

	#class_name = @attributes.last['name']
	#class_vals = @attributes.last['val']

	#class_vals.each do |key, val|
	#	@final[key] = Array.new(@attributes)
	#end
	
	#@final['<=50K.'] = @attributes
	#@final['>50K.'] = @attributes2
end

arff_file = File.open('data/adult.arff', 'r')

relation_name = nil
@attributes = Array.new()
@attributes2 = Array.new()
@missing_values = Array.new()
@types = Array.new


data = Foo.new
@classes = data.find_classes
@classes.each do |key, val|
	@final[key] = Array.new()
end
puts @classes
puts @final

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
			#puts attr_name
			attr_val = 0
			@types.push('num')
		end

		#@attributes[attr_name] = attr_val
		#val = Hash['name' => attr_name, 'val' => attr_val]
		#val2 = Hash['name' => attr_name, 'val' => attr_val]
		#@attributes.push(val)
		#@attributes2.push(val2)

		@classes.each do |_key, _val|
			name = _key
			@final[name].push(Hash['name' => attr_name, 'val' => attr_val])
			#puts name
			puts "Name:",@final[name]
		end

		#@final.each do |entry|
		#	entry.push(Hash['name' => attr_name, 'val' => attr_val])
		#end

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


		#puts clas
		for i in (0..line.size) do

			# figure out the type and do the appropriate thing
			if @types[i] == 'num' then

				# avg the data
				orig = @final[clas][i]['val']
				new = (orig.to_i + line[i].to_i)/2
				@final[clas][i]['val'] = new

			elsif @types[i] == 'cat' then

				# inc val for given cat
				@final[clas][i]['val'][line[i]] += 1
			end
		end
	end

	# debug block
	if j > 28 then break end
	j += 1
end

#@attributes.each do |key, val|
	#puts "#{key} => #{val}"
#end


	@final.each do |key2, val2|
		puts "#{key2} => #{val2}"
		puts '-'*50
	end

#puts @attributes
#puts @final['<=50K.']
#puts @final['>50K.']
#puts @attributes
#puts @attributes2
