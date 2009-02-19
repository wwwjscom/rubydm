class Xfold

  def initialize(parser)
    @parser = parser
  end

  def xfold(model)

    ten_percent = @parser.max_lines * 0.10

    (1..10).each do |i|

      test = Array.new
      model = Array.new

      start_test_data = ten_percent * (i-1)
      end_test_data = ten_percent * i

      j = 1

      f = File.open('data/descrete', 'r')
      while line = f.gets

        if j >= start_test_data and j <= end_test_data then
          test.push(line)
        else
          model.push(line)
        end
        j += 1
      end

      # build model and test data here

    end
  end
end
