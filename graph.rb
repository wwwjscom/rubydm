#!/usr/local/bin/ruby -w

class Graph

  attr_accessor :input_layer_hash

  def initialize  
  end

  # workaround, does what initalize should do
  def create(hidden, input = @input_layer_hash.size)  
    @num_hidden = hidden
    @num_input = input
    @total = input + hidden + 2
    @input_nodes = Array.new (input) { Array.new(3) }
    @hidden_nodes = Array.new (hidden) { Array.new(3) }
    @output_nodes = Array.new (2) { Array.new(3) }

    @arcs = Array.new (@total)
    (0..@total).each do |i|
      @arcs[i] = random_array (@total)
    end 
  end


  def random_array (n)
    return Array.new (n) { 
        |i|         
          r = rand (6) * 0.1
          if rand(2) == 0
            -r
          else
            r
          end
      }
  end

  def get_input_nodes ()
    return @input_nodes
  end

  def get_hidden_nodes ()
    return @hidden_nodes
  end

  def get_output_nodes ()
    return @output_nodes
  end

  def get_arcs ()
    return @arcs
  end

  def get_weight (i, j, layer)
    return @arcs[i][j]
  end
  def set_weight (i, j, w, layer)
    @arcs[i][j] = w
  end

  def get_theta (j, layer)
    if layer == :input
       return @input_nodes[j][0]
    elsif layer == :hidden
       j = j - @num_input
       return @hidden_nodes[j][0]
    else
       j = j - (@total-2)
       return @output_nodes[j][0]
    end 
  end   
  def set_theta (j, theta, layer)
    if layer == :input          
       @input_nodes[j][0] = theta
    elsif layer == :hidden
       j = j - @num_input
       @hidden_nodes[j][0] = theta
    else
       j = j - (@total-2)
       @output_nodes[j][0] = theta      
    end
  end

  def get_o (j, layer)
    if layer == :input
       return @input_nodes[j][1]
    elsif layer == :hidden
       j = j - @num_input
       return @hidden_nodes[j][1]
    else
       j = j - (@total-2)
       return @output_nodes[j][1]
    end
  end
  def set_o (j, o, layer)
    if layer == :input
       @input_nodes[j][1] = o
    elsif layer == :hidden
       j = j - @num_input
       @hidden_nodes[j][1] = o
    else
       j = j - (@total-2)
       @output_nodes[j][1] = o      
    end
  end
  
  def get_i (j, layer)
    if layer == :input
       return @input_nodes[j][2]
    elsif layer == :hidden
       j = j - @num_input
       return @hidden_nodes[j][2]
    else
       j = j - (@total-2)
       return @output_nodes[j][2]
    end
  end
  def set_i (j, i, layer)
    if layer == :input
       @input_nodes[j][2] = i
    elsif layer == :hidden
       j = j - @num_input
       @hidden_nodes[j][2] = i
    else
       j = j - (@total-2)
       @output_nodes[j][2] = i      
    end
  end

  def get_error (j, layer)
    if layer == :input
       return @input_nodes[j][3]
    elsif layer == :hidden
       j = j - @num_input
       return @hidden_nodes[j][3]
    else
       j = j - (@total-2)
       return @output_nodes[j][3]
    end
  end
  def set_error (j, error, layer)
    if layer == :input
       @input_nodes[j][3] = error
    elsif layer == :hidden
       j = j - @num_input
       @hidden_nodes[j][3] = error
    else
       j = j - (@total-2)
       @output_nodes[j][3] = error  
    end
  end

  def is_in_input_layer (j)
    if j < @input_nodes.length          
      return true
    else
      return false
    end
  end
  
  def is_in_hidden_layer (j)
    if j < @input_nodes.length          
      return false
    elsif j < @hidden_nodes.length
      return true
    else
      return false
    end
  end
  
  def is_in_output_layer (j)
    if j < @input_nodes.length          
      return false
    elsif j< @hidden_nodes.length
      return false
    else
      return true
    end
  end
  
  def input_node_indexes ()
    return [0, @input_nodes.length-1]
  end
  
  def hidden_node_indexes ()
    return [@input_nodes.length, @hidden_nodes.length-1]
  end
  
  def output_node_indexes ()
    return [@hidden_nodes.length, @output_nodes.length-1]
  end

  def hidden_back_connections (j)
    (0..(@hidden_nodes.length-1)).to_a
  end  

  # builds a hash for the input layer which contains a key
  # representing a possible attribute value and a value which
  # represents the index in the input layer array
  def input_layer_list(attributes, ranges_hash)
    input_layer_hash = Hash.new
    i = 0
    ranges_hash.each do |index, values|
      #puts index
      #puts attributes[index]['name']
      values.split(',').each do |value|
        input_layer_hash[value] = i
        i += 1
      end
    end

    attributes.each do |entry|
      name = entry['name']
      val = entry['val']
      if val != 0 then
        val.each do |_name, _val|
          input_layer_hash[_name] = i
          i += 1
        end
      end
    end

    @input_layer_hash = input_layer_hash
  end

  def set_i_with_array(arr, layer = nil)
    (0..(arr.length-1)).each do |i|
      set_i(i, arr[i], layer)
      set_o(i, arr[i], layer)
    end
  end

  def get_index_from_hash(attribute)
    @input_layer_hash[attribute]
  end

end
