class AddWelcomedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :welcomed_at, :datetime, index: true
    add_index :subscriptions, :welcomed_at
  end
end
