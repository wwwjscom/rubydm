#!/usr/local/bin/ruby -w

require "parser.rb"
require "entropy.rb"
require "xfold.rb"

class Runner

	def initialize ()
		@p = Parser.new
	end

	def parse_file ()

		# figure out how many claases we have, and the names
		@p.find_classes()

		# setup the structure that holds all the values
		@p.setup_structure()

		@p.read_file()

		@p.fill_in_missing_values()

		out = File.open('data/final', 'w')
		@p.final.each do |key, val|
			puts
		end

		########################
		# Start Discretization #
		########################
		e = Entropy.new(@p)
		sorted_frequency_hash = e.find_continous_attributes
		ranges_hash = e.discretize(sorted_frequency_hash)
		@p.replace_continous_attributes_with_categories(ranges_hash)

		xfold = Xfold.new(@p)

		xfold.xfold("model")
	
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
