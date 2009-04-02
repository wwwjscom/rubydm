#!/usr/local/bin/ruby -w

require "parser.rb"
require "entropy.rb"
require "xfold.rb"
require "bayes.rb"
require "decision_tree.rb"
require "graph.rb"
require "neural_network.rb"

class Runner

	def initialize ()
		@p = Parser.new
	end

	def parse_file (model)

    puts '-'*25
    puts '----------- PARSING --------------'
    puts '-'*25
		# figure out how many claases we have, and the names
		@p.find_classes()

		# setup the structure that holds all the values
		@p.setup_structure()

		@p.read_file()

    puts '-'*25
    puts '----------- MISSING VALS --------------'
    puts '-'*25
		@p.fill_in_missing_values()

#		out = File.open('data/final', 'w')
#		@p.final.each do |key, val|
#			pputs
#		end


		########################
		# Start Discretization #
		########################
    puts '-'*25
    puts '----------- ENTROPY --------------'
    puts '-'*25
		e = Entropy.new(@p)
		sorted_frequency_hash = e.find_continous_attributes
		ranges_hash = e.discretize(sorted_frequency_hash)
		@p.replace_continous_attributes_with_categories(ranges_hash)

    puts ranges_hash
    puts '-'*100
    puts @p.attributes
    puts '-'*100

    @graph = Graph.new
    nn = NeuralNetwork.new(@graph)
    @graph.input_layer_list(@p.attributes, ranges_hash)
    @graph.create(2)
    input_layer_array = parse_line_and_active_input_layer_array('17-52, 13492-382717')
    @graph.set_i_with_array(input_layer_array, :input)

    # Feed forward
    a = @graph.hidden_node_indexes
    (a[0]..a[1]).each do |hidden_node|
      puts hidden_node
      input_node_ranges = @graph.input_node_indexes
      (input_node_indexes[0]..input_node_indexes[1]).each do |input_node|
        i = input_node
        j = hidden_node
        nn.calc_input_to_node(j, :hidden)
        nn.get_o(j, :hidden)
        #nn.update_weight(i, j, 0.3)
      end
    end

    a = @graph.output_node_indexes
    (a[0]..a[1]).each do |output_node|
      hidden_node_ranges = @graph.hidden_node_indexes
      (hidden_node_indexes[0]..hidden_node_indexes[1]).each do |hidden_node|
        i = hidden_node
        j = output_node
        nn.calc_input_to_node(j, :output)
        nn.get_o(j, :output)
        #nn.update_weight(i, j, 0.3)
      end
    end

    # Feed backwards

    a = @graph.output_node_indexes
    (a[0]..a[1]).each do |output_node|
      hidden_node_ranges = @graph.hidden_node_indexes
      (hidden_node_indexes[0]..hidden_node_indexes[1]).each do |hidden_node|
        i = hidden_node
        j = output_node
        nn.update_weight(i, j, 0.3, :hidden)
        nn.calc_error(j, :output)
        nn.update_bias(j, 0.3, :output)
      end
    end

    a = @graph.hidden_node_indexes
    (a[0]..a[1]).each do |hidden_node|
      puts hidden_node
      input_node_ranges = @graph.input_node_indexes
      (input_node_indexes[0]..input_node_indexes[1]).each do |input_node|
        i = input_node
        j = hidden_node
        nn.update_weight(i, j, 0.3, :output)
        nn.calc_error(j, :hidden)
        nn.update_bias(j, 0.3, :hidden)
      end
    end


    puts @graph.get_arcs
    puts @graph.get_output_nodes
    puts @graph.get_input_nodes
    puts @graph.get_hidden_nodes

    return #DEBUG



    ###########################
    # GO GO GADGET DECISION TREE
    # #########################
    d = DecisionTree.new(@p, e)
#    order_list = d.order_attributes
#    #puts order_list
#    #return # DEBUG
#    d.build_tree
#    d.walk_tree("17-52, Private, 13492-382717, 11th, 1-7, Never-married, Machine-op-inspct, Own-child, Black, Male, 0-24998, 0-941, 25-49, United-States, <=50K.")
#    d.walk_tree("53-90, Self-emp-not-inc, 13492-382717, Prof-school, 8-16, Married-civ-spouse, Prof-specialty, Husband, White, Male, 0-24998, 0-941, 25-49, United-States, >50K.")
#    d.walk_tree("17-52, State-gov, 13492-382717, Some-college, 8-16, Married-civ-spouse, Exec-managerial, Husband, Black, Male, 0-24998, 0-941, 25-49, United-States, >50K.")
#    d.walk_tree("17-52, Private, 13492-382717, Assoc-voc, 8-16, Married-civ-spouse, Prof-specialty, Wife, White, Female, 0-24998, 0-941, 25-49, United-States, >50K.")
#
#    return # DEBUG

    # UNCOMMENT TO USE BAYES
		########################
		# Structure bays array #
		########################
#    puts '-'*25
#    puts '----------- CALC PROBABILITIES --------------'
#    puts '-'*25
#		bayes = Bayes.new(@p, ranges_hash)
#		bayes.create_new_attributes_list
#		tmp = @p.structure_array_based_on_attributes(true)


		##################
		# X-Fold it yo!! #
		##################
    puts '-'*25
    puts '----------- X-FOLDING --------------'
    puts '-'*25
		xfold = Xfold.new(@p)
    ### SET MODEL TO USE HERE
		xfold.xfold('decision_tree', d)
	end

	def debug ()
		@p.final.each do |key, val|
			puts "#{key} => #{val}"
			puts '-'*50
		end
	end

  def parse_line_and_active_input_layer_array(line)
    input_layer_array = Array.new(@graph.input_layer_hash.size, 0)
    line = line.split(', ')
    line.each do |attribute|
      index = @graph.get_index_from_hash(attribute)
      input_layer_array[index] = 1
    end

    input_layer_array
  end
end


run = Runner.new
run.parse_file(ARGV[0].to_s)

#run.debug
