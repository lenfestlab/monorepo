class UnconstrainPostSourceKey < ActiveRecord::Migration[5.2]
  def change
    change_column :posts, :source_key, :string, null: true
  end
end
