class RenameNameToUser < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :image_url, :sns_image
  end
end
