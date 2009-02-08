#!/usr/local/bin/ruby -w

class Foo

end

class Parser
	attr_accessor :name, :classes, :types, :final

	def initialize(name)
		@name = name
		@name = Array.new()
		@classes = Array.new()
		@types = Array.new()
		@final = Hash.new()
	end



		def get_types()
		return @types
	end

	def get_classes()
		return @classes
	end
end


relation_name = nil
@attributes = Array.new()
@attributes2 = Array.new()
@missing_values = Array.new()


data = Parser.new('whatever')
data.find_classes()
classes = data.get_classes()
puts classes
classes.each do |key, val|
	puts key
	@final[key] = Array.new()
	@key = Parser.new(key)
end
puts classes
puts @final
types = data.get_types()
puts "here"
#puts types


#@attributes.each do |key, val|
	#puts "#{key} => #{val}"
#end


	@final.each do |key2, val2|
		puts "#{key2} => #{val2}"
		puts '-'*50
	end

#puts @attributes
#puts @final['<=50K.']
#puts @final['>50K.']
#puts @attributes
#puts @attributes2
