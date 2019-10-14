class AddImageResource < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :resource, :string
    add_index :images, :resource
  end
end
