class AddGuideGroupCache < ActiveRecord::Migration[5.2]
  def change
    add_column :guide_groups, :cached_guides_count, :integer, default: 0
  end
end
