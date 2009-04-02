#!/usr/local/bin/ruby -w

class Graph
  def initialize (n)
    #@input_nodes    
    #@arcs

    @num_hidden = n  
    @hidden_nodes = random_array(n)      
    @output_nodes = random_array(2)
 
  end

  def random_array (n)
    return Array.new (n) 
      { 
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

  def layer? (j)
    if j < input_nodes.length          
      return "input"
    elsif j < hidden_nodes.length 
      return "hidden"
    else
      return "output"
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
end
