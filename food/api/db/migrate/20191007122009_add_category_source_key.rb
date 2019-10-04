class AddCategorySourceKey < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :source_key, :string
    add_column :categories, :is_craving, :boolean, default: false
  end
end
