class ColumnLogsCallbacks
  def after_create(column)
    content = "#{column.operator.name}さんが#{column.name}カラムを作成しました"
    Log.create!(content: content, project: column.project)
  end

  def after_update(column)
    return unless column.saved_change_to_name?
    content = "#{column.operator.name}さんが#{column.name_before_last_save}カラムの名前を#{column.name}に編集しました"
    Log.create!(content: content, project: column.project)
  end

  def after_destroy(column)
    return if column.operator.nil?
    content = "#{column.operator.name}さんが#{column.name}カラムを削除しました"
    Log.create!(content: content, project: column.project)
  end
end
