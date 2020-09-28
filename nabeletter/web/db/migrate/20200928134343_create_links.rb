class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.belongs_to :edition, null: false
      t.string :href, index: true, null: false
      t.string :section_name, index: true, null: false
      t.timestamps
    end
    add_index :links, [:edition_id, :href], unique: true
  end
end
