#!/usr/local/bin/ruby -w

require "parser.rb"
require "entropy.rb"
require "xfold.rb"
require "bayes.rb"
require "decision_tree.rb"

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

    d = DecisionTree.new(@p, e)
    order_list = d.order_attributes
    #puts order_list
    #return # DEBUG
    d.build_tree
    d.walk_tree("17-52, Private, 13492-382717, 11th, 1-7, Never-married, Machine-op-inspct, Own-child, Black, Male, 0-24998, 0-941, 25-49, United-States, <=50K.")
    d.walk_tree("53-90, Self-emp-not-inc, 13492-382717, Prof-school, 8-16, Married-civ-spouse, Prof-specialty, Husband, White, Male, 0-24998, 0-941, 25-49, United-States, >50K.")
    d.walk_tree("17-52, State-gov, 13492-382717, Some-college, 8-16, Married-civ-spouse, Exec-managerial, Husband, Black, Male, 0-24998, 0-941, 25-49, United-States, >50K.")
    d.walk_tree("17-52, Private, 13492-382717, Assoc-voc, 8-16, Married-civ-spouse, Prof-specialty, Wife, White, Female, 0-24998, 0-941, 25-49, United-States, >50K.")

    return # DEBUG

		########################
		# Structure bays array #
		########################
    puts '-'*25
    puts '----------- CALC PROBABILITIES --------------'
    puts '-'*25
		bayes = Bayes.new(@p, ranges_hash)
		bayes.create_new_attributes_list
		tmp = @p.structure_array_based_on_attributes(true)


		##################
		# X-Fold it yo!! #
		##################
    puts '-'*25
    puts '----------- X-FOLDING --------------'
    puts '-'*25
		xfold = Xfold.new(@p)
		xfold.xfold(bayes)
	end

	def debug ()
		@p.final.each do |key, val|
			puts "#{key} => #{val}"
			puts '-'*50
		end
	end
end


run = Runner.new
run.parse_file(ARGV[0].to_s)

#run.debug
