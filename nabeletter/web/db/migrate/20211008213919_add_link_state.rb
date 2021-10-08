class AddLinkState < ActiveRecord::Migration[6.0]
  def change
    add_column :links, :state, :integer, default: 0, index: true, null: false
    add_column :links, :channel, :integer, default: 0, index: true, null: false
    add_column :links, :lang, :integer, default: 0, index: true, null: false

    remove_index :links, ["edition_id", "href_digest"]
    remove_index :links, :href_digest
    add_index :links, :href_digest, unique: true
    add_column :links, :short, :string
    add_index :links, :short, unique: true

    change_column_null :links, :section_name, true
  end
end
