class Xfold

require "tester.rb"

  def initialize(parser)
    @parser = parser
  end

  # model is an object of the tests which we 
  # will be using, Bayes, decision tree, etc
  #
  # Run x-fold validation on that model
  def xfold(model_to_use)

    x = 0 # DEBUG
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

      micro_tester = Tester.new(@parser.classes)
      macro_tester = Tester.new(@parser.classes)
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

        max = 0
        predicted_class = nil
        probability.each do |__class, probability|
          if probability > max then
            predicted_class = __class
            max = probability
          end
        end

        actual_class = line[line.size-1]
        micro_tester.evaluate(predicted_class, actual_class)
        macro_tester.evaluate_macro(predicted_class, actual_class)

        #puts "Predicted class: #{predicted_class} with probability #{max}"
        #puts "...and the correct class was....#{actual_class}"
        #break # DEBUG break, remove ot check all attributes
      end

      puts macro_tester.confusion_matrix_c1
      puts '-'*5
      puts macro_tester.confusion_matrix_c2
      puts "Micro Recall: #{micro_tester.recall}"
      puts "Micro Precision: #{micro_tester.precision}"
      puts "Micro F-Measure: #{micro_tester.f_measure}"
      puts "Accuracy: #{micro_tester.accuracy}"


      puts "Macro Recall: #{macro_tester.recall_macro}"
      puts "Macro Precision: #{macro_tester.precision_macro}"
      puts "Macro F-Measure: #{macro_tester.f_measure_macro}"



#      puts '-'*50
#      model_to_use.test.each do |key, val|
#        puts key
#        puts val
#        puts '-'*50
#      end

      x += 1
      if x == 2 then break end # DEBUG
      #break # DEBUG remove me to make xfold run for all 10 runs
    end
  end
end
