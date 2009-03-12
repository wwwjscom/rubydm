#!/usr/local/bin/ruby -w

class Parser
	attr_accessor :classes, :types, :final, :missing_values, :attributes, :max_lines, :known_values, :number_of_entries, :attribute_name_index_list, :class_count, :attr_array


	def initialize ()
		@final = Hash.new()
		@types = Array.new() # holds whether an attribute is a cat or numeric value
		@classes = Array.new() # the classes of the file we are reading in...supposed to be the last column
		@missing_values = Array.new() # holds all missing entries, anything with a ? in it
		@known_values = Array.new() # holds the known entries (ie the line has no ?'s) which we'll write to a file @ max_lines
		@attributes = Array.new() # holds a list of attribute names
		@max_lines = 1000
		@number_of_entries = 0
    @attribute_name_index_list = Hash.new
    @attr_array = Array.new # does what the above should be doing...

		# delete any files laying around from a previous run
		begin
			File.delete('./data/missing_values')
			File.delete('./data/all_data')
			File.delete('./data/descrete')
			File.delete('./data/new_attr_list')
      File.delete('./data/test_data')
		rescue
		end
	end

	# This function will take 'all_data' file, which will
	# contain values that were once missing but were since guessed,
	# and read it in line by line, parsing out only the attribute
	# we case about.  It'll create a frequency of attribute values
	# and return a hash.  Must pass in the index (column) of the
	# desired attribute
  #
  # You can specify an alternate file to read as well
  #
  # You can also had classes added to the return datastructure
	def read_attribute_values(attribute_index, file = 'all_data', include_class_label = false)

		file = File.open("data/#{file}", 'r')
		@attr_frequency = Hash.new
    @class_count = Hash.new

		while line = file.gets
			line = line.chomp
			line = line.split(', ')
			line_attr_value = line[attribute_index].to_i

			if @attr_frequency.has_key?(line_attr_value)
				@attr_frequency[line_attr_value] += 1
			else
				@attr_frequency[line_attr_value] = 1
			end

      if include_class_label then
        class_label = line[line.size-1]
        if @class_count.has_key?(line_attr_value) then
          @class_count[line_attr_value][class_label] += 1
        else
          @class_count[line_attr_value] = Hash['<=50K.' => 0, '>50K.' => 0]
          @class_count[line_attr_value][class_label] = 1
        end
      end

		end

		file.close

		return @attr_frequency
	end


	def alternate_read_attribute_values(attribute_index, file = 'all_data', include_class_label = false)

		file = File.open("data/#{file}", 'r')
		@attr_frequency = Hash.new
    @class_count = Hash.new

		while line = file.gets
			line = line.chomp
			line = line.split(', ')
			line_attr_value = line[attribute_index]

			if @attr_frequency.has_key?(line_attr_value)
				@attr_frequency[line_attr_value] += 1
			else
				@attr_frequency[line_attr_value] = 1
			end

      if include_class_label then
        class_label = line[line.size-1]
        if @class_count.has_key?(line_attr_value) then
          @class_count[line_attr_value][class_label] += 1
        else
          @class_count[line_attr_value] = Hash['<=50K.' => 0, '>50K.' => 0]
          @class_count[line_attr_value][class_label] = 1
        end
      end

		end

		file.close

		return @attr_frequency
	end


  # returns the name of an attribute based on its index
  def get_attr_name(index)
    return @attributes.fetch(index)['name']
  end

  # returns the attribute index based on the attribute name
  def get_attr_index(name)
    i = 0
    @attributes.each do |attribute_hash|
      if attribute_hash.value?(name) then
        return i
      end
      i += 1
    end
  end


	# Scans the file line by line, attribute by attribute, looking for
	# any attributes which exist within the ranges_hash['attr_column_index'].
	# If it finds one, then it replaces its value with the range that
	# it falls into, it 4 would be replaced with 1-10
	def replace_continous_attributes_with_categories(ranges_hash)

		in_file = File.open('data/all_data', 'r')
		out_file = File.open('data/descrete', 'w')

		# loop over the lines of the file
		while line = in_file.gets
			line = line.chomp
			line = line.split(', ')

			# Go through the ranges hash and replace each lines index value
			# with the range that it belongs to
			ranges_hash.each do |attr_index, ranges|

				attr_index = attr_index.to_i
				split_ranges = ranges.split(',')
				attr_value = line[attr_index].to_i
				split_ranges.each do |range|
					range = range.split('-')
					# if the value falls within our range
					#puts "Is #{range[0].to_i} <= #{attr_value} or #{attr_value} <= #{range[1].to_i}" # DEBUG output
					if range[0].to_i <= attr_value and attr_value <= range[1].to_i then
						#puts "YES!" # DEBUG output
						line[attr_index] = range.join('-')
						break
					end
				end
			end

			out_file.puts line.join(', ')
		end

		in_file.close
		out_file.close
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

				# push the line onto our known values array so that
				# we can write it to a file for use later.
				@known_values.push(line)

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

			if j > @max_lines then 

				# if we've read in the max number of lines we can
				# store in memory, then write the missing_values
				# array to a file, clear it, and keep reading
				# (since we don't store the records in memory, only
				# the averages)

				write_values()
				@known_values.clear
				write_missing_values()
				@missing_values.clear()
				#break 
			end
			j += 1
		end

		arff_file.close()
	end


	def write_values()
		out = File.open('data/all_data', 'a')

		j = 0
		@known_values.each do |entry|
			out.puts entry
			j += 1
		end

		out.close()
		@number_of_entries += j
	end

	def write_missing_values ()
		out = File.open('data/missing_values', 'a')

		@missing_values.each do |entry|
			out.puts entry
		end

		out.close()
	end

	def fill_in_missing_values ()

		# clear out the known values array so we don't write any
		# values twice by accident
		@known_values.clear

		file = File.open('data/missing_values', 'r')

		while line = file.gets

			orig_line = line
			line.chomp!
			# entry has all values, lets process it
			line = line.split(', ')
			clas = line[line.length-1]

			for i in (0..line.size) do

				# figure out the type and do the appropriate thing
				if types[i] == 'num' then

					# avg the data


					if line[i] == '?' then
						#puts "Used to me: #{line[i]}"
						avg = find_avg(i, clas)
						line[i] = avg
						#puts "Now its: #{line[i]}"
					end

					orig = @final[clas][i]['val']
					new = (orig.to_i + line[i].to_i)/2
					@final[clas][i]['val'] = new

				elsif types[i] == 'cat' then

					# inc val for given cat

					if line[i] == '?' then
						#puts "Used to me: #{line[i]}"
						subclass_name = find_most_frequent(i, clas)
						line[i] = subclass_name
						#puts "Now its: #{line[i]}"
					end

					@final[clas][i]['val'][line[i]] += 1
				end

			end

			# add the line with all the the newly filled in values
			# to our known_values array, strip out some junk created
			# above.
			@known_values.push(line.to_s.tr('[]\"', ''))
		end

		write_values

		file.close()
	end


	# find the most frequest cat for a given class and attribute
	def find_most_frequent(i, clas)

		highest = 0
		name = nil

		@final[clas][i]['val'].each do |subclass_name, count|

			if count > highest then
				highest = count
				name = subclass_name
			end
		end
		return name
	end

	# find the avg for a given attribute for a given class
	def find_avg(i, clas)

		avg = @final[clas][i]['val']
		return avg	
	end

	def setup_structure ()

		puts "Classes: #{@classes}"
		@classes.each do |_class|
			@final[_class[0]] = structure_array_based_on_attributes()
			#puts "Class: #{_class[0]}"
			#puts '*'*50
		end
	end

  # Structure an array based on the attributes
  # which are given in the .arff file and returns
  # that array so that it can be populated
  #
  # use_new_attr_file says whether we should read
  # in the file which contains ranges instead of
  # continous #'s as attributes.
	def structure_array_based_on_attributes (use_new_attr_file = false)

    if use_new_attr_file then
      arff_file = File.open('data/new_attr_list', 'r')
    else
      arff_file = File.open('data/adult.arff', 'r')
    end
		tmp = Array.new()

		while line = arff_file.gets

      line = line.chomp

			if line[0] == '%' then 

				# ignore since its a comment

			elsif line =~ /@ATTRIBUTE/ then

				line = line[11..-1] # chop off the @ATTRIBUTE tag
				line = line.split(/\t+| /, 2)

				attr_name = line[0]
				attr_val = line[1]

        @attr_array.push(attr_name)

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
