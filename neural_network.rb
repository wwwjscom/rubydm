class NeuralNetwork

  def initialize(graph)
    @graph = graph
  end

  # Hidden node represents the j-th index of the node in the hidden layer
  def calc_input_to_node(j, layer)

    sum = 0
    # for each input layer node, do w_{ij} * O_i
    @graph.input_nodes.each do |input_node|
      
      # figure out the index
      i = @graph.input_nodes.index(input_node, layer)
      weight = @graph.get_weight(i, j, layer)
      sum += (weight * get_o(j, layer))
    end

    theta = @graph.get_theta(j, layer)

    i = sum + theta
    @graph.set_i(j, i, layer)
    return i
  end

  def get_o(j, layer)
    #if @graph.get_layer(j) == :input then
    if layer == :input then
      o = @graph.get_i(j, layer)
    else
      o = 1/(1+Math.exp(@graph.get_i(j, layer)))
    end
    @graph.set_o(j, o, layer)
    return o
  end

  def calc_error(j, layer)
     #layer = @graph.get_layer(j, layer)
     if layer == :hidden then
       error = _hidden_error(j, layer)
     else
       error = _output_error(j, layer)
     end
     @graph.set_error(j, error, layer)
  end

  def _output_error(j, layer)
    o = @graph.get_o(j, layer)
    #t = EXPECTED_CLASS... # Need to find a smart way to get this in here...
    # BUG BELOW!!!!
    t = 0 # Need to find a smart way to get this in here...
    o*(1-o)*(t-o)
  end

  def _hidden_error(j, layer)
    o = @graph.get_o(j, layer)
    sum = 0
    @graph.hidden_back_connections(j, layer).each do |node|
      sum += @graph.get_error(node, layer) * @graph.get_weight(node, layer)
    end
    o * (1-o) * sum
  end

  def calc_weight(i, j, l, layer)
    l * calc_error(j, layer) * get_o(i, layer)
  end

  def update_weight(i, j, l, layer)
    weight = @graph.get_weight(i, j, layer) + calc_weight(i, j, l, layer)
    @graph.set_weight(i, j, weight, layer)
  end

  def calc_bias(j, l, layer)
    l * calc_error(j, layer)
  end

  def update_bias(j, l, layer)
    theta = @graph.get_theta(j, layer) + calc_bias(j, l, layer)
    @graph.set_theta(j, theta, layer)
  end
end
