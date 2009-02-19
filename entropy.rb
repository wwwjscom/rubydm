class Entropy


  def initialize(parser)
    @parser = parser
  end

  # find out which one of our attributes are continuous.  Once
  # we find one that is, gather the frequency data on that attribute
  # and then add it to our hash which will contain the attributes
  # name, along with its frequency data, and return it.
  def find_continous_attributes

    continous_attributes_hash = Hash.new

    attributes_array = @parser.attributes.to_a
    attr_index = 0 
    @parser.types.each do |type|
      if type == 'num' then

        # get the attribute name
        attribute_name = attributes_array.fetch(attr_index)['name']

        puts '-'*200
        puts attribute_name + '' + attr_index.to_s
        puts '-'*200

        # find the frequency of each occurance within this attribute
        frequency_hash = @parser.read_attribute_values(attr_index)
        # sort it, for entropys sake
        sorted_frequency = frequency_hash.sort

        # Add that continous attribtue and its frequency entries
        # to our hash so we can return it later
        continous_attributes_hash[attribute_name] = sorted_frequency
      end 
      #return continous_attributes_hash # DEBUG RETURN, take this one out!!
      attr_index += 1
    end 

    return continous_attributes_hash
  end

  # Takes a hash of attributes and sorted freqeuncy data
  # (as calculated by find_continous_attributes), and will
  # find split points.  It'll continue to split until one
  # of the halt conditions is met, and return a hash which
  # contains the attribute name and the ranges for that
  # attribute.
  def discretize sorted_frequency

    # iterate over each attribtue and open up its attribute
    # name and its frequency
    sorted_frequency.each do |attribute_name, frequency_hash|
      # for each of the values in the hash/array, find their
      # probability (frequency/# of events)
      #find_best_split_point(frequency_hash)
      ranges = split(frequency_hash)
      puts "Recomended ranges for #{attribute_name} attribute are #{ranges}"
    end
  end


  # Looks through the passed in frequency_hash and tries
  # to find the best split points based on the entropy
  # of the ranges at the given split point. Returns the
  # best ranges in an array
  def find_best_split_point(min, max, frequency_hash)


  # setup base-case values

  split_point = (min.to_i + max.to_i)/2
  range_1 = "#{min}-#{split_point-1}"
  range_2 = "#{split_point}-#{max}"

  range_1_hash, range_2_hash = Hash.new, Hash.new


    # setup the range hashes.  We will use these to iterate
    # over and calculate the entropy of the range.
    frequency_hash.each do |attribute_label, frequency|
      if attribute_label.to_i < (split_point-1).to_i then
        range_1_hash[attribute_label] = frequency
      elsif attribute_label.to_i >= split_point.to_i then
        range_2_hash[attribute_label] = frequency
      end
    end

    range_1_frequency = sum_frequency_for_range(range_1_hash)
    range_2_frequency = sum_frequency_for_range(range_2_hash)

#    range_1_entropy = calc_entropy(range_1_frequency)
#    range_2_entropy = calc_entropy(range_2_frequency)
#
#    puts range_1_entropy
#    puts range_2_entropy

#    min_val = frequency_hash.min[0]
#    max_val = frequency_hash.max[0]
#    split_point = (min_val + max_val)/2
#    range_1 = "#{min_val}-#{split_point-1}"
#    range_2 = "#{split_point}-#{max_val}"
#
#    times += 1

  # debug block
#  puts min
#  puts max
#  puts split_point
#  puts range_1
#  puts range_2

  #return [range_1, range_2]
  return [range_1, range_1_frequency, range_2, range_2_frequency]
  end


  def split(frequency_hash)

    @max_entropy = false
    # setup base-case values
    min_val = frequency_hash.min[0]
    max_val = frequency_hash.max[0]

    split_point = (min_val + max_val)/2
    range_1 = "#{min_val}-#{split_point-1}"
    range_2 = "#{split_point}-#{max_val}"

    times = 0

    stack = Array.new

    stack.push(range_1)
    stack.push(range_2)
    ###################### WORKING ON BASE CASE #########################

    range_1_entropy, range_2_entropy = 0, 0
    while @max_entropy == false and times < 4  do
      new_stack = Array.new
#      puts "Stack @ TOP: #{stack}"
      i = 0
      stack.each do |entry|
#        puts "Entry: #{entry}"
        @e = entry.split(',')
        @new_e = ''

        j = 0
        @e.each do |range|
          if @max_entropy == true then 
#            puts "Entry is too high, giving back :#{stack.join(',')}"
            return stack.join(',')
            break
          end
          #puts range #DEBUG

#          puts "e: #{@e}"
          ranges = range.split('-')
          range_low = ranges[0]
          range_high = ranges[1]

          new_ranges = find_best_split_point(range_low, range_high, frequency_hash)

#          puts "New range 0: #{new_ranges[0]}"
#          puts "New range 1: #{new_ranges[2]}"
          e_1 = calc_entropy(new_ranges[1])
          e_2 = calc_entropy(new_ranges[3])

#          puts "Entropy 1: #{e_1}"
#          puts "Entropy 2: #{e_2}"

          if(e_1 > 0.5 or e_2 > 0.5)
            # stop, entropy of range is too high
            @max_entropy = true
            @new_e = "#{range_low}-#{range_high}"
            break
          else
            # Replace the previous range, e[j], to the new 2
            # ranges we just calcualted
            #@e.delete_at(j)
            if j == 0 then
              prefix = ''
            else
              prefix = ','
            end

            #@e.insert(j, "#{prefix}#{new_ranges[0]},#{new_ranges[1]}")
            @new_e += "#{prefix}#{new_ranges[0]},#{new_ranges[2]}"
            j += 1
          end
#          puts "Stack: #{stack}"
#          puts "New Stack: #{new_stack}"
#          #stack[i] = @e.to_s.tr(' []\"', '')
#          #new_stack[i] = @e.to_s.tr(' []\"', '')
          new_stack[i] = @new_e.to_s.tr(' []\"', '')
#          puts "Stack: #{stack}"
#          puts "New Stack: #{new_stack}"
        end
        i += 1
        times += 1
      end
#      puts "BOTTOM"*50
      stack = new_stack
    end

    return stack.join(',')

  end

  # sum up all of the frequencies for a given
  # range/partition
  def sum_frequency_for_range(range_hash)
    s_frequency = 0
    range_hash.each do |attribute_label, frequency|
      s_frequency += frequency
    end
    return s_frequency
  end



  # Takes in an attribute label (ie, 65 is the attribute
  # label for age) and a frequency count (10 people have
  # age 65) and returns the entropy.
  def calc_entropy(frequency)
    begin
    probability = (frequency.to_f/@parser.number_of_entries.to_f)
    entropy = probability * -1 * Math.log(probability, 2)
    rescue
      puts probability
      puts frequency
    end
    return entropy
  end
end
