class RemoveSnsImageFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :sns_image, :string
    rename_column :users, :my_image, :image
  end
end
