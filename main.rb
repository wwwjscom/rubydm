#!/usr/local/bin/ruby -w

require "parser.rb"
require "entropy.rb"
require "xfold.rb"
require "bayes.rb"

class Runner

	def initialize ()
		@p = Parser.new
	end

	def parse_file ()

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
run.parse_file()

#run.debug
