#!/usr/local/bin/ruby -w

require "parser.rb"

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

		#puts "before:"
		#@p.final.each do |key, val|
		#	puts "#{key} => #{val}"
		#	puts '-'*50
		#end

		@p.fill_in_missing_values()

		#puts "After:"
		#@p.final.each do |key, val|
		#	puts "#{key} => #{val}"
		#	puts '-'*50
		#end
	end
end

run = Runner.new
run.parse_file()
