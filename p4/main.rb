#!/usr/bin/ruby

require 'parser'
require 'logic'

c = ARGV[0].to_f # Confidence
s = ARGV[1].to_f # Support

puts c
puts s

@t = Parser.new('test_transactions.csv')
@p = Parser.new('test_products')

#@t = Parser.new('small_basket.dat')
#@p = Parser.new('Products')

@p.read_file
@t.read_file
@l = Logic.new(@t, @p, c, s)

def _debug(k)
  for i in (1..k)
    #puts "Item \t\t Freq. \t\t Support \t\t Confidence"
    #puts "-"*25
    @set = @l.find_c(i, @set)
    @set.each do |item|
      if i == 1 then
        #puts "#{item} \t\t #{@l.calc_freq(item)}"
      else
        #print "#{item} \t\t #{@l.calc_freq(item)} \t\t"
        #last = item.last
        #print @l.support(item[0..-2], last)
        #print "\t\t", @l.confidence(item[0..-2], last)
        #puts
      end
    end

    #puts "Itemsets @ #{i}: #{@set.size}"
    print @set.size, ','

    if i > 1
   #   @l.print_rules(@set)
   #   puts "\n\n"
      @l.count_rules(@set)
      @l.determine_top_rules(@set)
    end

  end

  print "\n\n"
  puts "Total rules: #{@l.total_rules}"
  @l.top_3_rules.each {|c, r| print "Confidence: #{c} \t\t\t Rule: #{r}\n"}
end

_debug(4)
