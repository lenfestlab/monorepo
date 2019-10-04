class AddPostNeedsEditorial < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :previously_reviewed, :boolean, default: false
    add_column :posts, :previously_unreviewed, :boolean, default: false
    add_column :posts, :is_2019_top_25, :boolean, default: false
  end
end
