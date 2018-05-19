class CreateCards < ActiveRecord::Migration[5.1]
  def change
    create_table :cards do |t|
      t.string :name, null: false
      t.date :due_date
      t.references :assignee, foreign_key: { to_table: :users }, null: false
      t.references :project, foreign_key: true, null: false
      t.references :column, foreign_key: true, null: false

      t.timestamps
    end
    add_index  :cards, [:project_id, :name], unique: true
  end
end
