#!/usr/bin/ruby

require 'parser'
require 'logic'

@t = Parser.new('test_transactions.csv')
@p = Parser.new('test_products')

#@t = Parser.new('small_basket.dat')
#@p = Parser.new('Products')

@p.read_file
@t.read_file
@l = Logic.new(@t, @p)

def _debug(k)
  for i in (1..k)
    puts "Item \t\t Freq. \t\t Support \t\t Confidence"
    puts "-"*25
    @set = @l.find_c(i, @set)
    @set.each do |item|
      if i == 1 then
        puts "#{item} \t\t #{@l.calc_freq(item)}"
      else
        print "#{item} \t\t #{@l.calc_freq(item)} \t\t"
        last = item.last
        print @l.support(item[0..-2], last)
        print "\t\t", @l.confidence(item[0..-2], last)
        puts
      end
    end

    puts "\n\n"
  end
end

_debug(2)
