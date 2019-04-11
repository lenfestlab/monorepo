class PostHiding < ActiveRecord::Migration[5.2]
  def change
    change_table :posts do |t|
      t.boolean :live, default: true, null: false
      t.index :live
    end
  end
end
