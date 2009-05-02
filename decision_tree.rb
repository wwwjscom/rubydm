class DecisionTree


  def initialize(p, e)
    @p = p
    @e = e

    @ignore_list = Array.new
    @max_result_array = Array.new
    @max_class_count_array = Array.new
    @tree = Hash.new


   
  end

  def add_line_to_model(line)
    f = File.open('data/decision_tree_model', 'a')
    f.puts line
    f.close
  end

  # in this case, calculate_frequencies referes to
  # walking our tree and building the model based
  # on gain ratio.  Just keeping this as a stub
  # to satisfy the xfold API
  def calculate_frequencies
    order_attributes(true)
    build_tree
  end

  # scans all attributes and calculates their gain ratio.
  # It then orders them based on that, and returns them.
  #
  # Xfold is true when being called by xfold.  IT causes
  # us to read in a different file (the file with the model
  # data) instead of the file with all the data
  def order_attributes(xfold = false)

    @ignore_list = Array.new
    @max_result_array = Array.new
    @max_class_count_array = Array.new
    @tree = Hash.new


    attr_results_array = Array.new
    attr_length = @p.attributes.size
    gain_ratio_array = Array.new
    class_count_array = Array.new

    puts "Reading in attributes"
    # read in all attributes counts and store the results
    (0..13).each do |x|
      puts "On #{x} out of 13"
      if xfold then
        result = @p.alternate_read_attribute_values(x, 'decision_tree_model', true)
        attr_results_array.push(result)

        class_count = @p.class_count
        class_count_array.push(class_count)

        gain_ratio = @e.gain_ratio(result, class_count).abs
        gain_ratio_array.push(gain_ratio)
      else
        result = @p.alternate_read_attribute_values(x, 'descrete', true)
        attr_results_array.push(result)

        class_count = @p.class_count
        class_count_array.push(class_count)

        gain_ratio = @e.gain_ratio(result, class_count).abs
        gain_ratio_array.push(gain_ratio)

      end
    end
    puts "Done reading"

    (0..13).each do |x| 
      max = -10000000
      max_class = nil 
      max_result = nil
      max_class_count = nil
      (0..13).each do |i| 
        class_label = @p.attributes[i]['name'].chomp
        if @ignore_list.include?(class_label) then next end
        #puts class_label
#        if xfold then
#          result = @p.alternate_read_attribute_values(i, 'decision_tree_model', true)
#        else
#          result = @p.alternate_read_attribute_values(i, 'descrete', true)
#        end
        #puts result
#        class_count = @p.class_count
        #puts class_count
        #puts '-'*100
#        gain_ratio = @e.gain_ratio(result, class_count).abs
#        if gain_ratio > max then 
        if gain_ratio_array[i] > max then 
#          max = gain_ratio 
#          max_class = class_label
#          max_result = result
#          max_class_count = class_count

          max = gain_ratio_array[i]
          max_class = class_label
          max_result = attr_results_array[i]
          max_class_count = class_count_array[i]

        end
        #puts '-'*100
      end
      #puts max
      #puts max_class
      #puts max_result
      #puts max_class_count
      @max_result_array.push(max_result)
      @max_class_count_array.push(max_class_count)
      @ignore_list.push(max_class)
    end

    return @ignore_list
  end

  # build the tree based.  Given an ordered list of
  # attributes, look at each of the values within the
  # attributes and determine if the ratio of one class
  # to another class is higher enough to declare a class
  # of ir we need to continue builting that part of the
  # tree.
  def build_tree
    index = 0
    @ignore_list.each do |attribute|
      #puts "Attribute: #{attribute}"
      #puts "Result: #{@max_result_array[index]}"
      #puts "Count: #{@max_class_count_array[index]}"

      @max_class_count_array[index].each do |label, count|
        isLeaf = false
        result = nil
        #puts "Label: #{label}, Count: #{count}"
        c1_count = count['<=50K.']
        c2_count = count['>50K.']
        ratio_a = c1_count.to_f / c2_count.to_f
        ratio_b = c2_count.to_f / c1_count.to_f
        #puts "ratio_a: #{ratio_a} || ratio_b: #{ratio_b} || c1: #{c1_count} || c2: #{c2_count}"
        if ratio_a >= 30 or ratio_b >= 30 then
          # Have a high ratio, thus we can declare a class
          if c1_count > c2_count
            # declare class 1
            #puts "Ratio is HIGH, #{ratio_a}, declare any #{attribute} with a #{label} to be class <=50K."
            isLeaf = true
            result = '<=50k'
          else
            #puts "Ratio B is HIGH, #{ratio_b}, declare any #{attribute} with a #{label} to be class >50K."
            isLeaf = true
            result = '>50k'
          end
        else
          #puts "Ratio is too LOW for #{attribute} with label #{label}."
        end

        if index == 0 then parent = nil else parent = @ignore_list[index-1] end

        if isLeaf then
          @tree[label] = Hash['attribute' => attribute, 'label' => label, 'isLeaf' => isLeaf, 'result' => result, 'child' => nil, 'parent' => parent]
        else
          @tree[label] = Hash['attribute' => attribute, 'label' => label, 'isLeaf' => isLeaf, 'result' => result, 'child' => @ignore_list[index+1], 'parent' => parent]
        end

      end
      index += 1
    end

    @tree.each { |node| puts node }
  end


  # Walks through a tree with a given record and declares
  # a class for it.
  def walk_tree(sample_entry)
    index = 0

    predicted_class = nil
    #puts sample_entry
    split_entry = sample_entry.split(', ')
    # label is name here
    set = false
    sample_entry.split(', ').each do |attribute_label|

      current_node = @ignore_list[index]
      #puts current_node
      label_index = @p.attr_array.index(current_node)
      #puts "Lable index: #{label_index}"
      sample_value = split_entry[label_index]
      #puts "Sample Value: #{sample_value}"
      node = @tree[sample_value]
      #puts "Node: #{node}"

      if node['result'] != nil then
        predicted_class = "#{node['result'].upcase}."
        #puts "---- CLASSIFICATION: #{node['result'].upcase}"
        set = true
        break
      end

      if node['child'] == nil then
        predicted_class = '>50K.'
        #puts "---- CLASSIFICATION: >50K."
        break
      end
      index += 1
    end

    return predicted_class

  end

  def get_number_of_leaves
    leaves = 0
    @tree.each do |node, thing|
      if thing['isLeaf'].to_s  == true then
        leaves += 1 
      end
    end
    return leaves.to_i
  end

end
