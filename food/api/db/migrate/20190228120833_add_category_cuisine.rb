class AddCategoryCuisine < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :is_cuisine, :boolean, default: false
  end
end
