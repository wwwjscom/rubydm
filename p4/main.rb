#!/usr/bin/ruby

require 'parser'
require 'logic'

#@t = Parser.new('test_transactions.csv')
#@p = Parser.new('test_products')

@t = Parser.new('small_basket.dat')
@p = Parser.new('Products')

@p.read_file
@t.read_file
@l = Logic.new(@t, @p)

def _debug(k)
  for i in (1..k)
    puts "Item \t\t Support"
    puts "-"*25
    @set = @l.find_c(i, @set)
    @set.each do |item|
      puts "#{item} \t\t #{@l.calc_freq(item)}"
    end

    puts "\n\n"
  end
end

_debug(2)
