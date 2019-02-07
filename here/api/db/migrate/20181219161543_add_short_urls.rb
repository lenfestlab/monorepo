class AddShortUrls < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :url_short, :string
  end
end
