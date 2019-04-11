class CategoryWindows < ActiveRecord::Migration[5.2]
  def change
    change_table :categories do |t|
      t.date :display_starts, index: true
      t.date :display_ends, index: true
    end
  end
end
