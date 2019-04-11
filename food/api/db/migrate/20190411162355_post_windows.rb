class PostWindows < ActiveRecord::Migration[5.2]
  def change
    change_table :posts do |t|
      t.date :display_starts
      t.date :display_ends
      t.index :display_starts
      t.index :display_ends
    end
    change_table :categories do |t|
      t.index :display_starts
      t.index :display_ends
    end

    change_table :places do |t|
      t.jsonb :cached_categories, default: [], array: true
      t.jsonb :cached_post, default: {}
      t.rename :nabe_cache, :cached_nabes
    end
  end
end
