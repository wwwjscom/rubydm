#!/usr/local/bin/ruby -w

class Graph

  def initialize  
  end

  # workaround, does what initalize should do
  def create(input, hidden)  
    @num_hidden = hidden
    @num_input = input
    @total = input + hidden + 2
    @input_nodes = Array.new (input)
    @hidden_nodes = Array.new (hidden)
    @output_nodes = Array.new (2)

    arcs = Array.new (@total)
    (0..@total).each do |i|
      arcs[i] = random_array (@total)
    end 
  end


  def random_array (n)
    return Array.new (n) { 
        |i|         
          r = rand (6) * 0.1
          if rand (2) == 0
            -r
          else
            r
          end
      }
  end

  def get_input_nodes ()
    return input_nodes
  end

  def get_hidden_nodes ()
    return hidden_nodes
  end

  def get_output_nodes ()
    return output_nodes
  end

  def get_arcs ()
    return arcs
  end

  def get_weight (i, j)
    return arcs[i][j]
  end
  def set_weight (i, j, w)
    arcs[i][j] = w
  end

  def get_theta (j)
    if j < input_nodes.length          
       return input_nodes[j][0]
    elsif j < hidden_nodes.length
       return hidden_nodes[j][0]
    else
       return output_nodes[j][0]
    end 
  end   
  def set_theta (j, theta)
    if j < input_nodes.length          
       input_nodes[j][0] = theta
    elsif j < hidden_nodes.length 
       hidden_nodes[j][0] = theta
    else
       output_nodes[j][0] = theta      
    end
  end

  def get_o (j)
    if j < input_nodes.length          
       return input_nodes[j][1]
    elsif j < hidden_nodes.length
       return hidden_nodes[j][1]
    else
       return output_nodes[j][1]
    end
  end
  def set_o (j, o)
    if j < input_nodes.length          
       input_nodes[j][1] = o
    elsif j < hidden_nodes.length 
       hidden_nodes[j][1] = o
    else
       output_nodes[j][1] = o      
    end
  end
  
  def get_i (j)
    if j < input_nodes.length          
       return input_nodes[j][2]
    elsif j < hidden_nodes.length
       return hidden_nodes[j][2]
    else
       return output_nodes[j][2]
    end
  end
  def set_i (j, i)
    if j < input_nodes.length          
       input_nodes[j][2] = i
    elsif j < hidden_nodes.length 
       hidden_nodes[j][2] = i
    else
       output_nodes[j][2] = i      
    end
  end

  def get_error (j)
    if j < input_nodes.length          
       return input_nodes[j][3]
    elsif j < hidden_nodes.length
       return hidden_nodes[j][3]
    else
       return output_nodes[j][3]
    end
  end
  def set_error (j, error)
    if j < input_nodes.length          
       input_nodes[j][3] = error
    elsif j < hidden_nodes.length 
       hidden_nodes[j][3] = error
    else
       output_nodes[j][3] = error  
    end
  end


  def get_layer (j)
    if j < input_nodes.length          
      return :input
    elsif j < hidden_nodes.length 
      return :hidden
    else
      return :output
    end
  end

  def is_in_input_layer (j)
    if j < input_nodes.length          
      return true
    else
      return false
    end
  end
  
  def is_in_hidden_layer (j)
    if j < input_nodes.length          
      return false
    elsif j < hidden_nodes.length
      return true
    else
      return false
    end
  end
  
  def is_in_output_layer (j)
    if j < input_nodes.length          
      return false
    elsif j< hidden_nodes.length
      return false
    else
      return true
    end
  end
  
  def input_node_indexes ()
    return [0, input_nodes.length-1]
  end
  
  def hidden_node_indexes ()
    return [input_nodes.length, hidden_nodes.length-1]
  end
  
  def output_node_indexes ()
    return [hidden_nodes.length, output_nodes.length-1]
  end

  def hidden_back_connections (j)
    (0..(hidden_nodes.length-1)).to_a
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

    input_layer_hash
  end

end
