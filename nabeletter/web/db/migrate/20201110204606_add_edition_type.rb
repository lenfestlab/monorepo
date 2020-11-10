class AddEditionType < ActiveRecord::Migration[6.0]
  def change
    add_column :editions, :kind, :integer, default: 0, index: true
  end
end
