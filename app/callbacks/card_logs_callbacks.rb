class CardLogsCallbacks
  def after_create(card)
    content = "#{card.operator.name}さんが#{card.name}カードを作成しました"
    Log.create!(content: content, project: card.project)
  end

  def after_save(card)
    due_date_log(card) if card.saved_change_to_due_date?
    assign_log(card) if card.saved_change_to_assignee_id?
  end

  def after_update(card)
    name_edit_log(card) if card.saved_change_to_name?
    move_log(card) if card.saved_change_to_column_id?
  end

  def after_destroy(card)
    if card.operator.nil?
      content = "#{card.column.name}カラムにある#{card.name}カードが削除されました"
    else
      content = "#{card.operator.name}さんが#{card.name}カードを削除しました"
    end
    Log.create!(content: content, project: card.project)
  end

  private

  def due_date_log(card)
    due_date_str = card.due_date ? I18n.l(card.due_date, format: :mmdd) : 'なし'
    content = "#{card.operator.name}さんが#{card.name}カードの期限を#{due_date_str}に設定しました"
    Log.create!(content: content, project: card.project)
  end

  def assign_log(card)
    content = "#{card.operator.name}さんが#{card.name}カードを#{card.assignee.name}さんにアサインしました"
    Log.create!(content: content, project: card.project)
  end

  def name_edit_log(card)
    content = "#{card.operator.name}さんが#{card.name_before_last_save}カードの名前を#{card.name}に編集しました"
    Log.create!(content: content, project: card.project)
  end

  def move_log(card)
    content = "#{card.operator.name}さんが#{card.name}カードを#{card.column.name}カラムに移動しました"
    Log.create!(content: content, project: card.project)
  end
end
