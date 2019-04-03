class RemoveCategoryConstraints < ActiveRecord::Migration[5.2]
  def change
    change_column :categories, :key, :string, null: true
    remove_index :categories, :key
  end
end
