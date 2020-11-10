class AddLinkHash < ActiveRecord::Migration[6.0]
  def change
    remove_index :links, name: "index_links_on_href"
    remove_index :links, name: "index_links_on_edition_id_and_href"
    add_column :links, :href_digest, :string, null: true
    Link.all.each { |l| l.update(href_digest: Digest::SHA2.hexdigest(l.href)) }
    change_column :links, :href_digest, :string, null: false
    add_index :links, :href_digest
    add_index :links, [:edition_id, :href_digest], unique: true
  end
end
