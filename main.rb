#!/usr/local/bin/ruby -w

require "parser.rb"
require "entropy.rb"

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


		########################
		# Start Discretization #
		########################
		e = Entropy.new(@p)
		e.find_continous_attributes
	
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
