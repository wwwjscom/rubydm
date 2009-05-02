#!/usr/bin/ruby -w
require "csv"

class Parser

  attr_accessor :file

  def initialize(filename)
    @filename = filename
  end

  # reads in the file and returns the array
  def read_file
    @file = CSV.read(@filename)
  end

end
