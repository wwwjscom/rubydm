class Xfold

  def initialize(parser)
    @parser = parser
  end

  # model is an object of the tests which we 
  # will be using, Bayes, decision tree, etc
  #
  # Run x-fold validation on that model
  def xfold(model_to_use)

    ten_percent = @parser.number_of_entries * 0.10

    (1..10).each do |i|

     # test_a = Array.new
     # model_a = Array.new

      start_test_data = ten_percent * (i-1)
      end_test_data = ten_percent * i

      j = 1

      f = File.open('data/descrete', 'r')
      test_model_file = File.open('data/test_data', 'w')
      while line = f.gets

        if j >= start_test_data and j <= end_test_data then
          test_model_file.puts(line)
          #model_to_use.add_line_to_test(line)
        else
          model_to_use.add_line_to_model(line)
        end
        j += 1
      end

      test_model_file.close
      f.close


      #################
      ## Build Model ##
      #################

      # calculate frequencies
      model_to_use.calculate_frequencies

      puts '-'*50
      model_to_use.model.each do |key, val|
        puts key
        puts val
        puts '-'*50
      end


      ################
      ## Test Model ##
      ################

      f = File.open('data/test_data', 'r')
      while line = f.gets
        line = line.chomp
        line = line.split(', ')

        # The name of the class attribute, so we can skip
        # it when we get to it, otherwise it'll thorw off
        # the math
        class_attr_name = @parser.attributes[@parser.attributes.size-1]['name']
        index = 0
        # iterate over all attribute values in an
        # entry in our test data and see what the
        # probability of it fitting into a specific
        # class in our model is
        probability = Hash.new
        line.each do |line_attr_value|
          if line_attr_value == nil then next end
          # check the probability in each of our classes
          @parser.classes.keys.each do |_class|
            attr_name = @parser.attribute_name_index_list.key(index)
            # if we didn't find the attribute index using the above
            # method (ie the attribute was originally a categorical value)
            # then search through our attributes list
            if attr_name == nil then
              attr_name = @parser.attributes[index]['name']
            end

            # don't run if we are looking at the class probability,
            # otherwise we'll be multiplying by either 1 or 0...
            if class_attr_name == attr_name then
              next
            end

            # get the probability for this specific class in our model
            attr_probability = model_to_use.get_attribute_value(_class, attr_name, line_attr_value)
#            puts "attr_probability #{attr_probability}"
#            orig_probability = probability[_class]
#            puts "orig_probability #{orig_probability}"
#            if orig_probability == nil then orig_probability = 0 end
#            tmp = attr_probability * orig_probability
#            probability[_class] = tmp
            begin
              probability[_class] *= attr_probability
            rescue
              # throws an error if we haven't yet given this
              # class an initial value
              probability[_class] = attr_probability
            end
          end
          index += 1
        end

        break # DEBUG break, remove ot check all attributes
      end

      puts probability
      puts '-'*50
      model_to_use.test.each do |key, val|
        puts key
        puts val
        puts '-'*50
      end

      break # DEBUG remove me to make xfold run for all 10 runs
    end
  end
end
