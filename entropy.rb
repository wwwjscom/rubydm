class Entropy

  attr_accessor :attribute_name_index_list

  def initialize(parser)
    @parser = parser
    @attribute_name_index_list = Hash.new
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

        @attribute_name_index_list[attribute_name] = attr_index

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

    return_hash = Hash.new
    # iterate over each attribtue and open up its attribute
    # name and its frequency
    sorted_frequency.each do |attribute_name, frequency_hash|
      # for each of the values in the hash/array, find their
      # probability (frequency/# of events)
      ranges = split(frequency_hash)
      return_hash[@attribute_name_index_list[attribute_name]] = ranges
      puts "Recomended ranges for #{attribute_name} attribute are #{ranges}"
    end

    return return_hash
  end


  # Takes in a range, and splits it into two new sub ranges.
  # Returns the new ranges along with their frequencies
  def find_best_split_point(min, max, frequency_hash)

    split_point = (min.to_i + max.to_i)/2
    range_1 = "#{min}-#{split_point-1}"
    range_2 = "#{split_point}-#{max}"

    range_1_hash, range_2_hash = Hash.new, Hash.new


    # take our original range, and split it into two new ones
    # based on our split poined calculated above
    frequency_hash.each do |attribute_label, frequency|
      if attribute_label.to_i < (split_point-1).to_i then
        range_1_hash[attribute_label] = frequency
      elsif attribute_label.to_i >= split_point.to_i then
        range_2_hash[attribute_label] = frequency
      end
    end

    range_1_frequency = sum_frequency_for_range(range_1_hash)
    range_2_frequency = sum_frequency_for_range(range_2_hash)

    return [range_1, range_1_frequency, range_2, range_2_frequency]
  end


  # Takes in a frequency hash which contains...stuff?  Can't remember
  # what it should contain right now...
  def split(frequency_hash)

    # setup base-case values
    @max_entropy = false
    min_val = frequency_hash.min[0]
    max_val = frequency_hash.max[0]

    split_point = (min_val + max_val)/2
    range_1 = "#{min_val}-#{split_point-1}"
    range_2 = "#{split_point}-#{max_val}"

    times = 0

    stack = Array.new

    stack.push(range_1)
    stack.push(range_2)

    range_1_entropy, range_2_entropy = 0, 0

    # base-case is done, lets drop into the recursive
    # loop
    
    while @max_entropy == false and times < 4  do
      new_stack = Array.new # temp stack
      i = 0
      stack.each do |entry|

        # ranges are curretnyl in form 1-10,11-20, etc
        # so split them by comma and then deal with each
        # range on its own
        @e = entry.split(',')
        @new_e = ''

        j = 0
        @e.each do |range|
          # pretty sure this is deprecated
          if @max_entropy == true then 
            return stack.join(',')
          end

          # split apart the range which is in the form
          # 1-10 so we can pass this in as min and max
          # values when looking for split points
          ranges = range.split('-')
          range_low = ranges[0]
          range_high = ranges[1]

          # find new ranges, and their frequencies
          new_ranges = find_best_split_point(range_low, range_high, frequency_hash)

          # use the frequencies of the new ranges to
          # find the entropy of the new ranges
          e_1 = calc_entropy(new_ranges[1])
          e_2 = calc_entropy(new_ranges[3])

          if(e_1 > 0.5 or e_2 > 0.5)
            # stop, entropy of range is too high
            @max_entropy = true
            return stack.join(',')
          else
            # replace the previous ranges with the
            # new ranges we just calculated
            if j == 0 then
              prefix = ''
            else
              prefix = ','
            end
            @new_e += "#{prefix}#{new_ranges[0]},#{new_ranges[2]}"
            j += 1
          end
          # push the new ranges to the stack
          new_stack[i] = @new_e.to_s.tr(' []\"', '')
        end
        i += 1
        times += 1
      end
      # set the tmp stack to the final stack
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



  # Takes in a frequency count (10 people [the freq] have
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
