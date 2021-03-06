class Tester

  attr_accessor :tp, :fp, :tn, :fn, :classes, :confusion_matrix_c1, :confusion_matrix_c2

  def initialize(classes)
    @tp, @fp, @tn, @fn = 0, 0, 0, 0
    @classes = classes
    @confusion_matrix_c1 = Hash['TP' => 0, 'FP' => 0, 'FN' => 0, 'TN' => 0] # class 1 confusion matrix
    @confusion_matrix_c2 = Hash['TP' => 0, 'FP' => 0, 'FN' => 0, 'TN' => 0] # class 2 confusion matrix
  end


  # Does macro-level calculations, the other simply does
  # micro-level calculations
  def evaluate_macro(predicted_class, actual_class)
    # Since this is macro, figoure out what the real
    # class is we should be looking at
#    puts "Params: #{predicted_class}, #{actual_class}"
#    puts "Actual class: #{actual_class}, Class 0: #{@classes.to_a[0][0]}"
    if actual_class == @classes.to_a[0][0] then
#      puts "They match"
      if predicted_class == @classes.to_a[0][0] then
        if predicted_class == actual_class then @confusion_matrix_c1['TP'] += 1 end
        if predicted_class != actual_class then @confusion_matrix_c1['FN'] += 1 end
      else
        if predicted_class == actual_class then @confusion_matrix_c1['FP'] += 1 end
        if predicted_class != actual_class then @confusion_matrix_c1['TN'] += 1 end
      end
    else
#      puts "They DONT match"
      if predicted_class == @classes.to_a[0][0] then
        if predicted_class == actual_class then @confusion_matrix_c2['TP'] += 1 end
        if predicted_class != actual_class then @confusion_matrix_c2['FN'] += 1 end
      else
        if predicted_class == actual_class then @confusion_matrix_c2['FP'] += 1 end
        if predicted_class != actual_class then @confusion_matrix_c2['TN'] += 1 end
      end
    end
  end

  def evaluate(predicted_class, actual_class)
#    puts "Evaluating...: #{predicted_class} and #{actual_class}"
#    if predicted_class == @classes.to_a[0][0] then
      if predicted_class == actual_class then @tp += 1 end
      if predicted_class != actual_class then @fn += 1 end
#    else
#      if predicted_class == actual_class then @fp += 1 end
#      if predicted_class != actual_class then @tn += 1 end
#    end
    @fp = @fn
    @tn = @tp
  end

  def accuracy
    puts "((#{@tp.to_f} + #{@tn.to_f})/(#{@tp.to_f} + #{@tn.to_f} + #{@fp.to_f} + #{@fn.to_f}))"
    return ((@tp.to_f + @tn.to_f)/(@tp.to_f + @tn.to_f + @fp.to_f + @fn.to_f))
  end

  def precision
    return ((@tp.to_f) / (@tp.to_f + @fp.to_f))
  end

  def precision_macro
    tp = (@confusion_matrix_c1['TP'].to_f + @confusion_matrix_c2['TP'].to_f)/2
    fp = (@confusion_matrix_c1['FP'].to_f + @confusion_matrix_c2['FP'].to_f)/2
    return ((tp)/(tp + fp))
  end

  def recall
    return ((@tp.to_f) / (@tp.to_f + @fn.to_f))
  end

  def recall_macro
    tp = (@confusion_matrix_c1['TP'].to_f + @confusion_matrix_c2['TP'].to_f)/2
    fn = (@confusion_matrix_c1['FN'].to_f + @confusion_matrix_c2['FN'].to_f)/2
    return ((tp)/(tp + fn))
  end

  def f_measure
    return ((2*recall*precision) / (recall + precision)).to_f
  end


  def f_measure_macro
    return ((2*recall_macro*precision_macro) / (recall_macro + precision_macro)).to_f
  end



end
