class AddPositionToColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :columns, :position, :integer
  end
end
