

class Graph
      input_nodes[]
      hidden_nodes[]
      output_nodes[]
      arcs[][]

      def init ()
      
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
end
