class NeuralNetwork

  def initialize(graph)
    @graph = graph
  end

  # Hidden node represents the j-th index of the node in the hidden layer
  def calc_input_to_node(j)

    sum = 0
    # for each input layer node, do w_{ij} * O_i
    @graph.input_nodes.each do |input_node|
      
      # figure out the index
      i = @graph.input_nodes.index(input_node)
      weight = @graph.get_weight(i, j)
      sum += (weight * get_o(j))
    end

    theta = @graph.get_theta(j)

    sum + theta
  end

  def get_o(j)
    if @graph.get_layer(j) == :input then
      @graph.get_i(j)
    else
      1/(1+Math.exp(@graph.get_i(j)))
    end
  end

  def calc_error(j)
     layer = @graph.get_layer(j)
     if layer == :hidden then
       _hidden_error(j)
     else
       _output_error(j)
     end
  end

  def _output_error(j)
    o = @graph.get_o(j)
    t = EXPECTED_CLASS... # Need to find a smart way to get this in here...
    o*(1-o)*(t-o)
  end

  def _hidden_error(j)
    o = @graph.get_o(j)
    sum = 0
    @graph.hidden_back_connections(j).each do |node|
      sum += @graph.get_error(node) * @graph.get_weight(node)
    end
    o * (1-o) * sum
  end

  def calc_weight(i, j, l)
    l * calc_error(j) * get_o(i)
  end

  def update_weight(i, j, l)
    weight = @graph.get_weight(i, j) + calc_weight(i, j, l)
    @graph.set_weight(i, j, weight)
  end

  def calc_bias(j, l)
    l * calc_error(j)
  end

  def update_bias(j, l)
    theta = @graph.get_theta(j) + calc_bias(j, l)
    @graph.set_theta(j, theta)
  end
end
