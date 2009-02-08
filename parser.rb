#!/usr/local/bin/ruby -w

class Parser
	attr_accessor :classes, :types, :final, :missing_values, :attributes

	def initialize ()
		@final = Hash.new()
		@types = Array.new()
		@classes = Array.new()
		@missing_values = Array.new()
		@attributes = Array.new()
	end

	# returns a hash of the classes
	def find_classes

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
				@attributes.push(val)

			elsif line =~ /@DATA/ then

				# do nothing
				@classes = @attributes.last['val']
				return

			end
		end
	end


	# add an attribute value to our types array
	def add_value(line)

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

		@classes.each do |_key, _val|
			name = _key
			@final[name].push(Hash['name' => attr_name, 'val' => attr_val])
			#puts name
			#puts "Name:",@final[name]
		end


	end

	def read_file ()

		arff_file = File.open('data/adult.arff', 'r')

		j = 0
		while line = arff_file.gets.chomp!

			if line[0] == '%' then 

				# ignore since its a comment

			elsif line =~ /@RELATION/ then

				relation_name = line[10..-1]

			elsif line =~ /@ATTRIBUTE/ then

				#@classes.each do |key, val|
				#	key.add_value(line)
				#end

			elsif line =~ /@DATA/ then

				# do nothing

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
					if types[i] == 'num' then

						# avg the data
						#puts clas
						#puts @final[clas]
						orig = @final[clas][i]['val']
						new = (orig.to_i + line[i].to_i)/2
						@final[clas][i]['val'] = new

					elsif types[i] == 'cat' then

						# inc val for given cat
						@final[clas][i]['val'][line[i]] += 1
					end
				end
			end

			# debug block
			if j > 28 then break end
			j += 1
		end
	end

	def setup_structure ()

		puts "Classes: #{@classes}"
		@classes.each do |_class|
			@final[_class[0]] = structure_me()
			puts "Class: #{_class[0]}"
			puts '*'*50
		end
	end

	def structure_me ()

		arff_file = File.open('data/adult.arff', 'r')
		tmp = Array.new()

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
				else
					attr_val = 0
				end

				val = Hash['name' => attr_name, 'val' => attr_val]
				tmp.push(val)

			elsif line =~ /@DATA/ then

				# do nothing
				return tmp

			end
		end
	end
end

p = Parser.new()
p.find_classes()

puts p.classes()

# setup the structure to hold all the values
p.setup_structure()

f = p.final
puts '5'*50

p.read_file()

f.each do |key, val|
	puts "#{key} => #{val}"
	puts '5'*50
end
#puts f['>50K.']
