class AddCategoryDesc < ActiveRecord::Migration[5.2]
  def change
    change_table :categories do |t|
      t.text :description
    end
  end
end
