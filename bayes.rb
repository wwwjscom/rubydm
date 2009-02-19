class Bayes

  attr_accessor :model, :test

  def initialize(parser, ranges_hash)
    @ranges_hash = ranges_hash
    @parser = parser

    create_new_attributes_list

    @model = Hash.new
    @test = Hash.new

    @parser.classes.each do |_class, val|
      @model[_class] = @parser.structure_array_based_on_attributes(true)
      @test[_class] = @parser.structure_array_based_on_attributes(true)
    end
  end


  # add the passed in line from xfold
  # to the given model array
  def add_line_to_model(line)
    #puts @model
    
    line = line.chomp
    line = line.split(', ')

    _class = line[line.size-1]
    #puts line[line.size-1]
    line.each do |_line|

      @model[_class].each do |attr_name, attr_val|

        if attr_name['val'].class == Hash then

          # we have a sub_hash here, find the attr_name
          # in this sub_hash and increment its value
          attr_name['val'].each do |_attr_name, _attr_val|
            if _attr_name == _line then
              attr_name['val'][_line] += 1
              break
            end
          end

          # pretty sure we never get to this else block...
        else
          # we have a normal value here, increment it
          attr_name['val'] += 1
          puts attr_name['val']
        end
      end
    end
  end

  # add the passed in line from xfold
  # to the given model array
  def add_line_to_test(line)
    #puts @model
    
    line = line.chomp
    line = line.split(', ')

    _class = line[line.size-1]
    #puts line[line.size-1]
    line.each do |_line|

      @test[_class].each do |attr_name, attr_val|

        if attr_name['val'].class == Hash then

          # we have a sub_hash here, find the attr_name
          # in this sub_hash and increment its value
          attr_name['val'].each do |_attr_name, _attr_val|
            if _attr_name == _line then
              attr_name['val'][_line] += 1
              break
            end
          end

          # pretty sure we never get to this else block...
        else
          # we have a normal value here, increment it
          attr_name['val'] += 1
          puts attr_name['val']
        end
      end
    end
  end


  # Takes in a line from xfold and calculates the
  # frequencies for the given attribute and given class.
  # Returns a hash embedded in a hash which contains
  # the frequencies for each attribute.  Thus, the
  # structure of the return will look like:
  #
  # Hash[class_name] => (Hash[attr_name] => frequency)
  #
  # Can also look like the following:
  #
  # Hash[class_name] => ( Hash[attr_name] => (Hash[attr_type] => freq))
  # ie:
  # Hash[<=50k] => (Hash[workclass] => (Hash[Self_Employed] => 10))
  #
  # Type is either model or test
  def calculate_frequencies

    #@parser.classes.keys.each do |_class|

    i = 0
    _class = @parser.classes.keys[0]
      @model[_class].each do |attr_name, attr_val|

        # we have a sub_hash here, find the attr_name
        # in this sub_hash and increment its value
        attr_name['val'].each do |_attr_name, _attr_val|
          j = 0
          #attr_name['val'][_line] += 1
          puts "#{_class}, #{attr_name['name']}, #{_attr_name}, #{_attr_val}"
          __attr_name = attr_name['name']
          #__attr_name = @model[_class].fetch(attr_name['name'])
          __sub_attr_name = _attr_name
          __attr_val = _attr_val

          # loop and figure out the total count for the attribute
          attr_total = 0
          @parser.classes.keys.each do |__class|
            attr_total += @model[__class][i]['val'][__sub_attr_name]
          end
          puts "Attr total: #{attr_total}"
          # loop and figure out the class count for the attribute,
          # then replace its value with the probability
          @parser.classes.keys.each do |__class|
            count = @model[__class][i]['val'][__sub_attr_name]
            puts "Class: #{__class}"
            puts "Count: #{count}"
            probability = count.to_f/attr_total.to_f
            @model[__class][i]['val'][__sub_attr_name] = probability
            puts "Probability: #{probability}"
          end

          j += 1
        end
        i += 1
      end
      #end

  end


  # Recursively seeks through the attributes array
  # for a specific class until it finds that attribute
  # label, then returns its value
  #
  # Optionaly specify a sub_attribute to get an exact
  # value back, instead of a hash contain all values for
  # each sub_attribute of the specified attribute
  def get_attribute_value(_class, attribute, sub_attribute = nil)

    @model[_class].each do |attr_name, attr_val|

      if attr_name['val'].class == Hash then

        # we have a sub_hash here, find the attr_name
        # in this sub_hash and increment its value
        attr_name['val'].each do |_attr_name, _attr_val|

          #puts "Checking to see if #{_attr_name} matches #{attribute}"
          #puts "Checking to see if #{attr_name['name']} matches #{attribute}"
          if attr_name['name'] == attribute then
            if sub_attribute == nil then
              puts "Value of #{attribute} for class #{_class} is #{attr_name['val']}"
              return attr_name['val']
            else
              puts "Value of #{attribute}'s subattribute #{sub_attribute} for class #{_class} is #{attr_name['val'][sub_attribute]}"
              return attr_name['val'][sub_attribute]
            end
          end
        end

        # pretty sure we never get to this else block...
      else
        # we have a normal value here, increment it
        attr_name['val'] += 1
        puts attr_name['val']
      end
    end
  end

  # Write our new attributes list to a file.  The
  # new list now include the ranges we just calcualted
  # based on entropy.  This new file can then be used
  # by the parser to structure an array based on our
  # attributes.
  def create_new_attributes_list

    f = File.open('data/new_attr_list', 'w')
    old_attributes_list = @parser.structure_array_based_on_attributes

    index = 0

    old_attributes_list.each do |attr_name, attr_val|

      string = "@ATTRIBUTE #{attr_name['name']} "

      if attr_name['val'].class == Hash then

        string += "{"
        # we have a sub_hash here, find the attr_name
        # in this sub_hash and increment its value
        attr_name['val'].each do |_attr_name, _attr_val|
          string += _attr_name[_attr_name] + ','
        end

        string = string[0..-2] # cut off the last comma, not needed
        string += "}\n"

      else
        # we have a normal value here, increment it
        string += "{#{@ranges_hash[index]}}"

      end

      f.puts string

      index += 1
    end

    # put this line because this is what he parser will
    # expect to hit before returning the array
    f.puts "@DATA"
    f.close
  end



end
