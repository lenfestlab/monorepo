class ArchivePostUrls < ActiveRecord::Migration[5.2]
  def change
    rename_column :posts, :url, :url_archived
    add_column :posts, :url, :text
  end
end
