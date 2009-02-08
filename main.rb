#!/usr/local/bin/ruby -w

require "parser.rb"

class Runner

	def initialize ()
		@p = Parser.new
	end

	def parse_file ()

		@p.find_classes()
		@p.setup_structure()
		@p.read_file()

		#@p.final.each do |key, val|
		#	puts "#{key} => #{val}"
		#	puts '5'*50
		#end

		puts @p.missing_values.size
	end
end

run = Runner.new
run.parse_file()
