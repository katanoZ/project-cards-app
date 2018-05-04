class AddMyImageToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :my_image, :string
  end
end
