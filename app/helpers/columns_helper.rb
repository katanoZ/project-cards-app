module ColumnsHelper
  def arrow_class(column, direction)
    if (column.first? && direction == :previous) || (column.last? && direction == :next)
      'text-middle-purple hover-middle-purple invisible'
    else
      'text-middle-purple hover-middle-purple'
    end
  end
end
