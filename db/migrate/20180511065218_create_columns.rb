class CreateColumns < ActiveRecord::Migration[5.1]
  def change
    create_table :columns do |t|
      t.string :name, null: false
      t.references :project, foreign_key: true, null: false

      t.timestamps
    end
    add_index  :columns, [:project_id, :name], unique: true
  end
end
