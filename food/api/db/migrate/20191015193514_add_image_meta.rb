class AddImageMeta < ActiveRecord::Migration[5.2]
  def change
    change_table :images do |t|
      t.string :title
      t.string :filename
      t.string :source_key
    end
    add_index :images, :source_key
  end
end
