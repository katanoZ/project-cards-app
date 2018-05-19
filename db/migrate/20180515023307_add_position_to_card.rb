class AddPositionToCard < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :position, :integer, null: false
  end
end
