class Logic

  MIN_FREQ = 1200

  def initialize(transactions, products, freq = 4)
    @p = products
    @t = transactions
    @total_p = @p.file[0].size
    @total_t = @t.file[0].size
    @infreq_sets = Array.new
    @products = Array.new
    setup_products_array
  end

  # P(A intersect B)
  def support(a, b)
    # num of transactions w/A and B
    # over
    # total number of transactions
    #puts "A:#{a[0]}"
    #puts "B:#{b}"
    #puts calc_freq([a[0], b])
    #puts @t.file.size
    #a = a.collect{ |x| "#{x},"}
    #a[-1] = a.last.chop
    arr = Array.new
    a.each do |x|
      arr << x
    end
    arr << b
    (calc_freq(arr).to_f / @t.file.size.to_f)
  end

  # P(B|A)
  def confidence(a, b)
    arr = Array.new
    a.each do |x|
      arr << x
    end
    arr << b
    (calc_freq(arr).to_f / calc_freq(a))
  end

  def find_c(k, set = nil)

    new_set = Array.new

    if k == 1
      #@p.file[0].each { |e| new_set << e }
      @products.each do |p|
        if calc_freq(p) > MIN_FREQ
          new_set << p 
        else
          @infreq_sets << p
        end
      end
    else
      set.each do |item_set|
        set.each do |item_set_2|
          candidate_set = (item_set.to_a | item_set_2.to_a).sort
          freq = calc_freq(candidate_set)

          if candidate_set.size == k and freq > MIN_FREQ and !@infreq_sets.include?(candidate_set) and !new_set.include?(candidate_set)
            new_set << candidate_set
          elsif freq <= MIN_FREQ and !@infreq_sets.include?(candidate_set)
            @infreq_sets << candidate_set
          end

        end
      end
    end

    # DEBUG LOOP
    @infreq_sets.each do |x|
      print "[#{x}], "
    end
      puts

    return new_set
  end

  def setup_products_array
    @p.file.each { |p| @products << p[0] }
  end

  def calc_freq(set)
    freq = 0
    @t.file.each do |purchase|
      match = true
      set.each do |item|
        #index = @p.file[0].index(item)
        index = @products.index(item)
        #puts "Item:",item
        #puts "Index:",index
        if purchase[index].to_i == 0
          match = false
          break
        end
      end

      if match
        freq += 1
      end

    end

    return freq
  end


  def find_c_set(k, set = nil)
    file = @t.file
    sum_array = Array.new(@total_t, 0)

    if k == 1
      file.each do |purchase|
        i = 0
        purchase.each do |item|
          sum_array[i] += item.to_i
          i += 1
        end
      end
    else
      # if k > 1
      _find_c_set(set) 
    end

    return sum_array
  end

  def _find_c_set(set)
    set_a = Array.new
      #puts "Set: #{set}"
    set.each do |item|
      #puts "Item #{item}"
      #set_a << set | item.to_a
    end

    return set_a
  end

end
