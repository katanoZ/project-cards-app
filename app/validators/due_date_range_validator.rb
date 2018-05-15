class DueDateRangeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.between?(Date.today, Date.today.next_year)
    record.errors[attribute] << (options[:message] || 'は今日から1年後までの範囲で入力してください')
  end
end
