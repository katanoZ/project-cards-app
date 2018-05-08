class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :summary
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end

    add_index :projects, :name, unique: true
  end
end
