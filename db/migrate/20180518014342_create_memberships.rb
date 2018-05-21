class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.references :project, foreign_key: { on_delete: :cascade }, null: false
      t.references :user, foreign_key: { on_delete: :cascade }, null: false
      t.boolean :join, null: false, default: false

      t.timestamps
    end
    add_index :memberships, [:project_id, :user_id], unique: true
  end
end
