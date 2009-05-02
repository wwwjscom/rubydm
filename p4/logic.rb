class Logic

  def initialize(parser, freq = 4)
    @p = parser
  end

  # P(A intersect B)
  def support(a, b)
    total = @p.file.size
    # num of transactions w/A and B
    # over
    # total number of transactions
  end

  # P(B|A)
  def confidence(a, b)
  end

end
