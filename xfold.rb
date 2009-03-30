class Xfold

  require "tester.rb"

  def initialize(parser)
    @parser = parser
  end

  # model is an object of the tests which we 
  # will be using, Bayes, decision tree, etc
  #
  # Run x-fold validation on that model
  def xfold(model_to_use, model_object)

    accuracy = 0
    micro_recall = 0
    micro_precision = 0
    micro_f = 0
    macro_recall = 0
    macro_precision = 0
    macro_f = 0

    #x = 0 # DEBUG
    ten_percent = @parser.number_of_entries * 0.10

    (1..10).each do |i|

      puts '-'*25
      puts "----------- X-FOLD - Test #{i} --------------"
      puts '-'*25

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
          model_object.add_line_to_model(line)
        end
        j += 1
      end

      test_model_file.close
      f.close


      #################
      ## Build Model ##
      #################

      # calculate frequencies
      model_object.calculate_frequencies

      #puts '-'*50
      #model_to_use.model.each do |key, val|
      #  puts key
      #  puts val
      #  puts '-'*50
      #end


      ################
      ## Test Model ##
      ################

      micro_tester = Tester.new(@parser.classes)
      macro_tester = Tester.new(@parser.classes)
      f = File.open('data/test_data', 'r')
      while line = f.gets

        #########################
        ####### BAYES SHIT ######
        #########################

        if model_to_use == 'bayes' then

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
              attr_probability = model_object.get_attribute_value(_class, attr_name, line_attr_value)

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


        elsif model_to_use == 'decision_tree' then

          #########################
          ####### DEC.T SHIT ######
          #########################

          predicted_class = model_object.walk_tree(line).to_s

          max = nil # DEBUG
          line = line
          line = line.split(', ')
        end

        actual_class = line[line.size-1]

        # WTF WHY CANT IT MATCH STRINGS NOW?!?
        puts "Evaluating...: #{predicted_class} and #{actual_class}"
        if predicted_class == '<=50K.' then
          predicted_class = 0
        else
          predicted_class = 1
        end

        if actual_class == '<=50K.' then
          actual_class = 0
        else
          actual_class = 1
        end

        micro_tester.evaluate(predicted_class.to_s, actual_class.to_s)
        macro_tester.evaluate_macro(predicted_class, actual_class)

        #puts "Predicted class: #{predicted_class} with probability #{max}"
        #puts "...and the correct class was....#{actual_class}"
        #break # DEBUG break, remove ot check all attributes
      end

      puts '-'*10
      puts "Accuracy: \t\t#{micro_tester.accuracy}"
      puts '-'*10
      puts "Micro Recall: \t\t#{micro_tester.recall}"
      puts "Micro Precision: \t#{micro_tester.precision}"
      puts "Micro F-Measure: \t#{micro_tester.f_measure}"
      puts '-'*10
      puts "Macro Recall: \t\t#{macro_tester.recall_macro}"
      puts "Macro Precision: \t#{macro_tester.precision_macro}"
      puts "Macro F-Measure: \t#{macro_tester.f_measure_macro}"
      puts '-'*10
      puts "General Error: \t\t#{1-micro_tester.accuracy}"
      puts "Pessimistic Error: \t\t#{((micro_tester.tn + micro_tester.tp + model_object.get_number_of_leaves * 0.5)/j)}"


      # Track averages
      accuracy += micro_tester.accuracy
      micro_recall += micro_tester.recall
      micro_precision += micro_tester.precision
      micro_f += micro_tester.f_measure
      macro_recall += macro_tester.recall_macro
      macro_precision += macro_tester.precision_macro
      macro_f += macro_tester.f_measure_macro

      #      puts '-'*50
      #      model_object.test.each do |key, val|
      #        puts key
      #        puts val
      #        puts '-'*50
      #      end

      #x += 1
      #if x == 1 then break end # DEBUG
      #break # DEBUG remove me to make xfold run for all 10 runs
    end


    puts '-'*25
    puts "----------- X-FOLD - AVERAVES --------------"
    puts '-'*25

    puts '-'*10
    puts "Accuracy: \t\t#{accuracy/10}"
    puts '-'*10
    puts "Micro Recall: \t\t#{micro_recall/10}"
    puts "Micro Precision: \t#{micro_precision/10}"
    puts "Micro F-Measure: \t#{micro_f/10}"
    puts '-'*10
    puts "Macro Recall: \t\t#{macro_recall/10}"
    puts "Macro Precision: \t#{macro_precision/10}"
    puts "Macro F-Measure: \t#{macro_f/10}"
    puts '-'*10




  end
end
