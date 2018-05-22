class CreateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :logs do |t|
      t.text :content, null: false
      t.references :project, foreign_key: true, null: false

      t.timestamps
    end
  end
end
