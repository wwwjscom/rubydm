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
      return continous_attributes_hash # DEBUG RETURN, take this one out!!
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
      find_best_split_point(frequency_hash)
    end
  end


  def find_best_split_point(frequency_hash)


    # find initial split points
    min_val = frequency_hash.min[0]
    max_val = frequency_hash.max[0]
    split_point = (min_val + max_val)/2
    range_1 = "#{min_val}-#{split_point-1}"
    range_2 = "#{split_point}-#{max_val}"
    range_1_hash = Hash.new
    range_2_hash = Hash.new

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

    range_1_entropy = calc_entropy("balls", range_1_frequency)[1]
    range_2_entropy = calc_entropy("balls", range_2_frequency)[1]

    # debug block
    puts min_val
    puts max_val
    puts split_point
    puts range_1
    puts range_2
    return


      frequency_hash.each do |attribute_label, frequency|
        attribute_label, entropy = calc_entropy(attribute_label, frequency)
        #puts "Entropy for #{attribute_name} @ value #{attribute_label} is #{entropy}"
        puts "Entropy for _something_  @ value #{attribute_label} is #{entropy}"
      end
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
  def calc_entropy(attribute_label, frequency)
    probability = (frequency.to_f/@parser.number_of_entries.to_f)
    entropy = probability * -1 * Math.log(probability, 2)
    return [attribute_label, entropy]
  end
end
