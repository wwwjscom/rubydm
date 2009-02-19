class Xfold

  def initialize(parser)
    @parser = parser
  end

  # model is an object of the tests which we 
  # will be using, Bayes, decision tree, etc
  #
  # Run x-fold validation on that model
  def xfold(model)

    ten_percent = @parser.number_of_entries * 0.10

    (1..10).each do |i|

     # test_a = Array.new
     # model_a = Array.new

      start_test_data = ten_percent * (i-1)
      end_test_data = ten_percent * i

      j = 1

      f = File.open('data/descrete', 'r')
      while line = f.gets

        if j >= start_test_data and j <= end_test_data then
          model.add_line_to_model('test', line)
        else
          model.add_line_to_model('model', line)
        end
        j += 1
      end

      f.close
      # build model and test data here

      puts '-'*50
      model.model.each do |key, val|
        puts key
        puts val
        puts '-'*50
      end
      puts '-'*50

      # calculate frequencies
      model.calculate_frequencies
      break
    end
  end
end
