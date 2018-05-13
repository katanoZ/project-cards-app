class ChangeColumnNullToColumns < ActiveRecord::Migration[5.1]
  def change
    change_column_null :columns, :position, false
  end
end
