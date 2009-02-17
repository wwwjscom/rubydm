class Entropy


  def initialize(parser)
    @parser = parser
  end

  # find out which one of our attributes are continuous
  def find_continous_attributes

    attributes_array = @parser.attributes.to_a
    i = 0 
    @parser.types.each do |type|
      if type == 'num' then
        # get the attribute name
        attribute_name = attributes_array.fetch(i)['name']
        #puts attribute_name # DEBUG

        # for each of our classes, combine the values of this
        # attribute, then sort them.
        attribute_values = 0
        @parser.classes.each do |_class, val|
          attribute_values += @parser.final[_class].fetch(i)['val'] # get the value of the attribute for the class
        end
        puts "Name: #{attribute_name} => #{attribute_values}"
      end 
      i += 1
    end 
  end
end
